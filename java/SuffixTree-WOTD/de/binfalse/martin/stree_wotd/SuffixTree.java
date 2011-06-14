/**
*
*     written by Martin Scharm
*      see http://binfalse.de
*
*/

package de.binfalse.martin.stree_wotd;

public class SuffixTree
{
	private SuffixTreeNode root;
	
	public void insert (String word)
	{
		root = new SuffixTreeNode();
		String [] suffix = new String [word.length()];
		for (int i = 0; i < word.length(); i++)
			suffix[i] = word.substring(i);
		root.insert(suffix, word.length());
	}
	
	public void printDotCode ()
	{
		System.out.println ("digraph G {");
		root.printDotCode (0);
		System.out.println ("}");
	}
	
	public void minimalUniqueSubstring ()
	{
		root.minimalUniqueSubstring ("");
	}
	
	public void maximalRepeats (String word)
	{
		root.maximalRepeats ("", word);
	}
	
}
