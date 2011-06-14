/**
*
*     written by Martin Scharm
*      see http://binfalse.de
*
*/

package de.binfalse.martin;

import de.binfalse.martin.stree_wotd.*;

public class Demo
{
	public static void main(String [] args)
	{
		SuffixTree meinBaum = new SuffixTree();
		meinBaum.insert("ababc$");
		
		// for graphviz
		meinBaum.printDotCode ();
		System.out.println();
		
		meinBaum.minimalUniqueSubstring ();
		System.out.println();
		
		meinBaum.maximalRepeats("ababc$");
	}
}