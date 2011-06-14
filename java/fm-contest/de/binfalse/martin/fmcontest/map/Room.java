/**
 * freies Magazin Contest 2010 - Einreichung
 * 
 * 
 * Copyright (C) 2010  Martin Scharm, http://binfalse.de
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 * 
 * 
 * For more information visit http://binfalse.de
 * 
 */
package de.binfalse.martin.fmcontest.map;

import java.util.Vector;

/**
 * Room
 * 
 * @author Martin Scharm
 */
public class Room
{
	private Vector<Point> points;
	private Vector<Door> neighbors;
	private double mx, my;
	public Point mid;
	
	public Room ()
	{
		points = new Vector<Point> ();
		neighbors = new Vector<Door> ();
		mx = -1;
		my = -1;
		mid = new Point ();
	}
	
	public Vector<Door> getNeigbors ()
	{
		return neighbors;
	}
	public Vector<Point> getPoints ()
	{
		return points;
	}
	
	public void addNeighbor (Door n)
	{
		neighbors.add (n);
	}
	
	public void addPoint (Point p)
	{
		points.add (p);
	}
	
	public void calcMid ()
	{
		mx = 0;
		my = 0;
		if (points.size () > 0)
		{
			for (int i = 0; i < points.size (); i++)
			{
				mx += points.elementAt (i).x;
				my += points.elementAt (i).y;
			}
			mx /= (double) points.size ();
			my /= (double) points.size ();
		}
		
		double dist = Double.MAX_VALUE;
		
		for (int i = 1; i < points.size (); i++)
			if (points.elementAt (i).dist (mx, my) < dist)
			{
				mid = points.elementAt (i);
				dist = points.elementAt (i).dist (mx, my);
			}
	}
}
