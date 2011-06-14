/**
 *
 *     written by Martin Scharm
 *      see http://binfalse.de
 *
 */

package de.binfalse.martin.stree_wotd;

import java.util.HashMap;
import java.util.Iterator;
import java.util.ArrayList;

public class SuffixTreeNode
{
	private HashMap <Character, SuffixTreeEdge> outEdges;
	private int leafIndex;
	
	public SuffixTreeNode ()
	{
		outEdges = new HashMap <Character, SuffixTreeEdge>();
		leafIndex = -1;
	}
	
	public SuffixTreeNode (int Blattindex)
	{
		outEdges = new HashMap <Character, SuffixTreeEdge>();
		this.leafIndex = Blattindex;
	}
	
	public void insert (String [] suffix, int wordlen)
	{
		HashMap <Character, ArrayList<String>> group = new HashMap <Character, ArrayList<String>> ();
		
		for (int i = 0; i < suffix.length; i++)
		{
			if (group.get (suffix[i].charAt (0)) == null)
				group.put (suffix[i].charAt (0), new ArrayList<String> ());
			group.get (suffix[i].charAt (0)).add (suffix[i]);
		}

		Iterator iterator = group.keySet ().iterator ();
		while (iterator.hasNext ())
		{
			char key = (Character) iterator.next ();
			ArrayList<String> list = group.get (key);
			
			if (list.size () == 1)
			{
				SuffixTreeEdge newEdge = new SuffixTreeEdge ();
				newEdge.setEdgeLabel (list.get (0));
				newEdge.setStart (this);
				newEdge.setEnd (new SuffixTreeNode (wordlen-list.get (0).length ()));
				outEdges.put (key, newEdge);
			}
			else
			{
				String lcp = list.get (0);
				for (int i = 1; i < list.size(); i++)
					lcp = longestCommonPrefix (lcp, list.get (i));
				SuffixTreeEdge newEdge = new SuffixTreeEdge ();
				newEdge.setEdgeLabel (lcp);
				newEdge.setStart (this);
				newEdge.setEnd (new SuffixTreeNode());
				outEdges.put (key, newEdge);
				
				String [] newSuffix = new String [list.size ()];
				
				for (int i = 0; i < list.size (); i++)
					newSuffix[i] = list.get (i).substring (lcp.length ());
				
				newEdge.getEnd ().insert (newSuffix, wordlen - lcp.length ());
			}
		}
	}
	
	public String longestCommonPrefix (String word1, String word2)
	{
		for (int i = 0; i < word1.length () && i < word2.length (); i++)
		{
			if (word1.charAt (i) != word2.charAt (i))
				return word1.substring (0, i);
		}
		if (word1.length () < word2.length ())
			return word1;
		else return word2;
	}
	
	public int printDotCode (int myNum)
	{
		System.out.println (myNum + " [label = \"" + ((leafIndex >= 0) ? leafIndex : "") + "\"];");
		Iterator iterator = outEdges.keySet ().iterator ();
		int childNum = myNum + 1;
		while (iterator.hasNext ())
		{
			char key = (Character) iterator.next ();
			System.out.println (myNum + " -> " + childNum + " [label = \"" + outEdges.get (key).getEdgeLabel () + "\"];");
			childNum = outEdges.get (key).getEnd ().printDotCode (childNum);
		}
		return childNum;
	}
	
	public void minimalUniqueSubstring (String pathLabel)
	{
		Iterator iterator = outEdges.keySet ().iterator ();
		while (iterator.hasNext ())
		{
			char key = (Character) iterator.next ();
			if (outEdges.get (key).getEnd ().getLeafIndex () >= 0)
				System.out.println ("minimal unique substring: " + pathLabel + outEdges.get (key).getEdgeLabel ().charAt (0));
			else
				outEdges.get (key).getEnd ().minimalUniqueSubstring (pathLabel + outEdges.get (key).getEdgeLabel ());
		}
	}
	
	public int getLeafIndex ()
	{
		return leafIndex;
	}
	
	
	public HashMap <Integer, String> maximalRepeats (String pathLabel, String word)
	{
		HashMap <Integer, String> leafIndices = new HashMap <Integer, String> ();
		char preChar;
		
		if (leafIndex >= 0)
		{
			if (leafIndex == 0)
				preChar = '$';
			else
				preChar = word.charAt (leafIndex - 1);
			
			leafIndices.put (leafIndex, "" + preChar);
			
			return leafIndices;
		}
		else
		{
			Iterator iterator = outEdges.keySet ().iterator ();
			while (iterator.hasNext ())
			{
				char key = (Character) iterator.next ();
				HashMap <Integer, String> childMap = outEdges.get (key).getEnd ().maximalRepeats (pathLabel + outEdges.get (key).getEdgeLabel (), word);
				
				Iterator childIterator = childMap.keySet ().iterator ();
				while (childIterator.hasNext ())
				{
					int childKey = (Integer) childIterator.next ();
					
					Iterator leafIterator = leafIndices.keySet ().iterator ();
					while (leafIterator.hasNext ())
					{
						int knownKeys = (Integer) leafIterator.next ();
						
						if (!leafIndices.get (knownKeys).equals (childMap.get (childKey)) && pathLabel.length () != 0)
							System.out.println ("maximal repeat: " + pathLabel);
					}
				}
				leafIndices.putAll (childMap);
			}
			return leafIndices;
		}
	}
	
}
