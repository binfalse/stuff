#include <cv.h>
#include <highgui.h>
#include <iostream>

using namespace std;


void usage ()
{
	cout << "vidsplit --input FILE [--prefix PREFIX]" << endl;
}

int main(int argc, char *argv[])
{
	string video = "";
	string prefix = "vidsplit_";
	int iteration = 0;
	
	for (int i = 1; i < argc; i++)
	{
		string akt (argv[i]);
		if (i < argc - 1)
		{
			if (akt == "--input")
			{
				video = argv[i + 1];
				i++;
				continue;
			}
			if (akt == "--prefix")
			{
				prefix = argv[i + 1];
				i++;
				continue;
			}
		}
	}
	
	if (video.length () < 1)
	{
		usage ();
		return 1;
	}
	
	CvCapture *capture = cvCaptureFromAVI(video.c_str());
	if (capture)
	{
		IplImage* frame;
		while (frame = cvQueryFrame(capture))
		{
			stringstream file;
			file << prefix << iteration << ".png";
			cvSaveImage(file.str ().c_str (), frame);
			iteration++;
		}
	}
	cvReleaseCapture( &capture );
	
	return 0;
}

