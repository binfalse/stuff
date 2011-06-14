package de.binfalse.martin;


/**********************************
 *
 *    written by Martin Scharm
 *     see https://binfalse.de
 *
 **********************************/


public class Zbox
{
	private int [] z;
	private char [] text;
	
	public Zbox ()
	{
		z = null;
		text = null;
	}
	
	public int findPrefixLength (char [] text, int a, int b)
	{
		int len = 0;
		for(int i = 0; i + a < text.length && i + b < text.length; i++)
		{
			if (text[i + a] == text[i + b]) len++;
			else break;
		}
		return len;
	}
	
	public void calcZbox (String word)
	{
		text = word.toCharArray ();
		z = new int [text.length];
		int l=0;
		int r=0;
		
		if (z.length > 1) z[1] = findPrefixLength (text, 0, 1);
		else return;
		
		if (z[1] > 0)
		{
			l = 1;
			r = z[1];
		}
		
		for (int j = 2; j < text.length; j++)
		{
			if (j > r) //case 1
			{
				z[j] = findPrefixLength (text, 0, j);
				if (z[j] > 0)
				{
					l = j;
					r = j + z[j] - 1;
				}
			}	
			else //case 2
			{
				int k = j - l;
				if (z[k] < r - j + 1) //case 2a
				{
					z[j] = z[k];
				}
				else //case 2b
				{
					int p = findPrefixLength (text, r - j + 1, r + 1);
					z[j] = r - j + 1 + p;
					l = j;
					r = j + z[j] - 1;
				}
			}
		}
	}
	
	public String toString ()
	{
		String s = "ZBoxes:\n";
		for (int i = 0; i < text.length; i++)
			s += text[i] + "\t";
		s += "\n\t";
		for (int i = 1; i < z.length; i++)
			s += z[i] + "\t";
		return s + "\n";
	}
	
	public static void main (String [] args)
	{
		Zbox z = new Zbox ();
		for (int i = 0; i < args.length; i++)
		{
			z.calcZbox (args[i]);
			System.out.println (z);
		}
	}
}
