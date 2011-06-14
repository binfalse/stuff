#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <cv.h>
#include <highgui.h>
#include <iostream>
#include <vector>
#include <time.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <errno.h>
#include <fstream>


using namespace std;


class Bubble
{
	private:
		CvPoint center;
		int radius;
	public:
		Bubble (CvPoint c, int r)
		{
			center = c;
			radius = r;
		}
		//draw this bubble in an image
		void draw (CvArr* img)
		{
			cvCircle( img, center, radius, CV_RGB (0, 0, 255), -1 );
			cvCircle( img, center, radius, CV_RGB (0, 0, 100), 5 );
		}
		//move this bubble down
		int move (int vel)
		{
			center.y += vel;
			return center.y;
		}
		//where is this bubble?
		CvPoint getCenter ()
		{
			return center;
		}
};

// recursivly create directories aka mkdir -p
void mkdir_p(const string &pathname)
{
	if (mkdir(pathname.c_str(), 0777) < 0) {
		if (errno == ENOENT)
		{
			size_t slash = pathname.rfind('/');
			if (slash != string::npos)
			{
				string prefix = pathname.substr(0, slash);
				mkdir_p(prefix);
				mkdir(pathname.c_str(), 0777);
			}
		}
	}
}

//is a file present?
bool file_exists (string filename) {
	ifstream fin;
	fin.open (filename.c_str());
	if (fin.fail()) return false;
	fin.close();
	return true;
}

//writing the highscore
void write_highscore (string path, string player, int punkte)
{
	cout << "Highscore: " << endl;
	string file = path + "highscore.txt";
	//is there any highscoretable?
	if (file_exists (file))
	{
		ifstream alt;
		alt.open (file.c_str(), ios::in | ios::binary);
		string buffer;
		stringstream output;
		bool written = false;
		//parse the old table
		while(!alt.eof())
		{
			getline (alt, buffer);
			int pos = buffer.find_first_of (':');
			if (pos != string::npos)
			{
				int p = atoi(buffer.substr(0, pos).c_str ());
				if (!written && p < punkte)
				{
					output << punkte << ':' << player << '\n';
					written = true;
				}
				output << buffer << '\n';
			}
		}
		if (!written) output << punkte << ':' << player << '\n';
		alt.close ();
		//write the new table
		ofstream neu;
		neu.open (file.c_str (), ios::out | ios::binary);
		cout << output.str () << endl;
		neu << output.str ();
		neu.close ();
	}
	else
	{
		//create new table
		ofstream fout;
		fout.open (file.c_str (), ios::out | ios::binary);
		if (fout.fail())
		{
			cout << "couldn't write highscore, unable to open " << file << endl;
			return;
		}
		fout << punkte << ":" << player;
		cout << punkte << ":" << player;
		fout.close();
	}
}

//read the configfile
void parse_config (string path, int &threshold)
{
	string file = path + "config.txt";
	if (file_exists (file))
	{
		ifstream config;
		config.open (file.c_str(), ios::in | ios::binary);
		string buffer;
		while(!config.eof())
		{
			getline (config, buffer);
			if (buffer.size () < 2) continue;
			//trim left
			buffer = buffer.substr(buffer.find_first_not_of(" \t"));
			//trim right
			buffer = buffer.substr(0, buffer.find_last_of("1234567890") + 1);
			//kommentar
			if (buffer[0] == '#') continue;
			
			//is this line interesting?
			if (buffer.find ("threshold") != string::npos)
			{
				threshold = atoi (buffer.substr(buffer.find_last_not_of("1234567890")).c_str ());
				continue;
			}
		}
		config.close ();
	}
}

//write the config after calibrating
void write_config (string path, int threshold)
{
	string file = path + "config.txt";
	ofstream fout;
	fout.open (file.c_str (), ios::out | ios::binary);
	if (fout.fail())
	{
		cout << "couldn't write config, unable to open " << file << endl;
		return;
	}
	fout << "threshold " << threshold << endl;
	fout.close();
}

//some variable directories
string GAMENAME ("bubbles");
string HOMEDIR (getenv ("HOME"));
string GAMEDIR = HOMEDIR + "/.esmz-designz/" + GAMENAME + "/";




int main(int argc, char *argv[])
{
	string player ("");
	bool video = false, calibrate = false;
	
	//parse args
	for (int i = 1; i < argc; i++)
	{
		string akt (argv[i]);
		if (akt == "-video")
		{
			video = true;
			continue;
		}
		if (akt == "-calibrate")
		{
			calibrate = true;
			continue;
		}
		player = akt;
	}
	
	//is everything fine?
	if ((!calibrate && player == "") || argc < 2)
	{
		cout << "USAGE: \n\t" << argv[0] << " [-video] name \t start game as player [name] and optional cature video" << endl;
		cout << '\t' << argv[0] << " -calibrate \t calibrate cam" << endl;
		return 0;
	}
	
	//input comes from cam
	CvCapture *capture = cvCaptureFromCAM(0);
	if (capture)
	{
		//take a test to find out if it works
		IplImage* test = cvQueryFrame(capture);
		if (!test)
		{
			printf("Could not load image\n");
			cvReleaseCapture( &capture );
			return 0;
		}
		
		//create directory if not already exists
		mkdir_p (GAMEDIR);
		
		
		int i , j , k , bubble_radius = 20, level = 1, punkte = 0, speed = 3, bubble_wk = 20, threshold = 27;
		char c;
		bool changed = false, found = false, quit = false;
		CvScalar s;
		CvFont font;
		double hScale = 0.7, vScale = 0.7;
		//init random
		srand ( time(NULL) );
		
		//create the vector of bubbles
		vector<Bubble*> bubbles;
		
		//parse the config file
		parse_config (GAMEDIR, threshold);
		
		//set up a font
		cvInitFont(&font,CV_FONT_HERSHEY_SIMPLEX|CV_FONT_ITALIC, hScale,vScale,0,1);
		//create the window
		cvNamedWindow("bubbles", CV_WINDOW_AUTOSIZE);
		cvMoveWindow("bubbles", 100, 100);
		
		//we need some images to calc
		IplImage *lastframe = 0;
		IplImage *diff = 0;
		IplImage *thresh = 0;
		IplImage *grey = 0;
		
		//capture the video (divx)
		CvVideoWriter *writer;
		if (video && !calibrate)
		{
			CvSize videosize;
			videosize.width = test->width;
			videosize.height = test->height;
			time_t t;
			t = time(0);
			tm *date = localtime(&t);
			stringstream videofile;
			videofile << GAMEDIR << "video_" << player << "_" << (date->tm_year+1900) << "-" << (date->tm_mon+1) << "-" << date->tm_mday << "_" << date->tm_hour << "-" << date->tm_min << ".avi";
			writer = cvCreateAVIWriter( videofile.str ().c_str (), CV_FOURCC('D', 'I', 'V', 'X'), 10, videosize);
		}
		
		//clock to time levels
		clock_t start = clock();
		
		while (!quit)
		{
			//is it time to level-up
			if (start + 10000000 < clock ())
			{
				level++;
				switch (level)
				{
					case 2:
						bubble_wk = 30;
						bubble_radius = 15;
						speed = 5;
						break;
					case 3:
						bubble_wk = 40;
						bubble_radius = 12;
						speed = 10;
						break;
					case 4:
						bubble_wk = 55;
						bubble_radius = 10;
						speed = 15;
						break;
					case 5:
						bubble_wk = 70;
						bubble_radius = 7;
						speed = 25;
						break;
				}
				start = clock();
			}
			
			//get actual image
			IplImage* img = cvQueryFrame(capture);
			if (!img)
			{
				printf("Could not load image\n");
				break;
			}
			//rotate for the brain
			cvFlip (img, 0, 1);
			
			//generate random bubbles
			if (!calibrate && rand() % 100 < bubble_wk)
			{
				CvPoint p;
				p.x = 20 + rand () % (img->width - 40);
				p.y = 5;
				bubbles.push_back (new Bubble (p, bubble_radius));
			}
			
			//calculate some stuff
			if ( !lastframe ) lastframe = cvCreateImage(cvGetSize(img),8,3);
			if ( !diff ) diff = cvCreateImage( cvGetSize(img), 8, 3 );	    
			if ( !thresh ) thresh = cvCreateImage( cvGetSize(img), 8, 1 );
			if ( !grey ) grey = cvCreateImage( cvGetSize(img), 8, 1 );
			cvAbsDiff( img, lastframe, diff );	// diff
			cvCvtColor( diff, grey, CV_BGR2GRAY );	// ein farbkanal
			cvThreshold( grey, thresh, threshold, 255, 1 );
			cvCopy( img, lastframe );	// frame fuer naechste runde
			
			
			//test every bubble
			vector<Bubble*>::iterator it = bubbles.begin ();
			while(it != bubbles.end ())
			{
				//move it, when one bubble reaches the bottom, the game is over
				if((*it)->move (speed) > thresh->height)
				{
					it =bubbles.erase(it);
					quit = true;
					break;
				}
				//does the player touch this bubble?
				found = false;
				int cX = (*it)->getCenter ().x;
				int cY = (*it)->getCenter ().y;
				for (int x = -bubble_radius; x <= bubble_radius; x++)
				{
					for (int y = -bubble_radius; y <= bubble_radius; y++)
					{
						if (sqrt(x*x + y*y) < bubble_radius && cX + x < thresh->width && cX + x >= 0 && cY + y < thresh->height && cY + y >= 0)
						{
							if (cvGet2D(thresh,cY + y,cX + x).val[0] == 0)
							{
								punkte += level * 10;
								it = bubbles.erase(it);
								found = true;
								break;
							}
						}
					}
					if (found) break;
				}
				if (found) continue;
				(*it)->draw (img);
				it++;
			}
			
			//hud
			stringstream str;
			str << "level: " << level << " Punkte: " << punkte << " Player: " << player;
			cvPutText( img, str.str().c_str(), cvPoint(20,20), &font, cvScalar(0,0,0));
			
			//show the image
			if (calibrate) cvShowImage("bubbles", thresh );
			else cvShowImage("bubbles", img );
			if (video && !calibrate) cvWriteFrame(writer,img);
			
			
			//change some settings?
			c = cvWaitKey(2);
			if ( c == 27 ) break;
			if ( c == 'f' ) { changed = true; threshold++; }
			if ( c == 'v' ) { changed = true; threshold--; if (threshold < 0) threshold = 0; }
			
			if (changed)
			{
				cout << threshold << endl;
				changed = false;
			}
		}
		//write highscore
		if (!calibrate && punkte > 0) write_highscore (GAMEDIR, player, punkte);
		//if calibrating write the new values to config
		if (calibrate) write_config (GAMEDIR, threshold);
		
		//tidy up
		cvReleaseImage( &lastframe );
		cvReleaseImage( &diff );
		cvReleaseImage( &thresh );
		cvReleaseCapture( &capture );
		if (video && !calibrate) cvReleaseVideoWriter(&writer);
	}
	
	return 0;
}

