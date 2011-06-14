/**
*
*     written by Martin Scharm
*      see http://binfalse.de
*
*/

package de.binfalse.martin.stree_wotd;

public class SuffixTreeEdge
{
	private String edgeLabel;
	private SuffixTreeNode start, end;
	
	public SuffixTreeEdge ()
	{
		edgeLabel = "";
		start = null;
		end = null;
	}
	
	public void setEdgeLabel (String EdgeLabel)
	{
		this.edgeLabel = EdgeLabel;
	}
	
	public String getEdgeLabel ()
	{
		return edgeLabel;
	}
	
	public void setStart (SuffixTreeNode start)
	{
		this.start = start;
	}
	
	public SuffixTreeNode getStart ()
	{
		return start;
	}
	
	public void setEnd (SuffixTreeNode end)
	{
		this.end = end;
	}
	
	public SuffixTreeNode getEnd ()
	{
		return end;
	}
	
	
}