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

/**
 * @author Martin Scharm
 */
public class Point
{
	public int x, y;
	public Point ()
	{
		x = y = 0;
	}
	public Point (int x, int y)
	{
		this.x = x;
		this.y = y;
	}
	public Point (Point b)
	{
		x = b.x;
		y = b.y;
	}
	public Point sum (Point b)
	{
		return new Point (x + b.x, y + b.y);
	}
	public Point add (int b)
	{
		return new Point (x + b, y + b);
	}
	public Point minus (Point b)
	{
		return new Point (x - b.x, y - b.y);
	}
	public Point minus (int b)
	{
		return new Point (x - b, y - b);
	}
	public Point transposed ()
	{
		return new Point (-y, x);
	}
	public int crossProd (Point b)
	{
		return x * b.x + y * b.y;
	}
	public double dist (double x, double y)
	{
		return Math.sqrt ((x - this.x)*(x - this.x) + (y - this.y)*(y - this.y));
	}
	public double dist (int x, int y)
	{
		return Math.sqrt ((x - this.x)*(x - this.x) + (y - this.y)*(y - this.y));
	}
	public double dist (Point p)
	{
		return Math.sqrt ((p.x - this.x)*(p.x - this.x) + (p.y - this.y)*(p.y - this.y));
	}
	public String toString ()
	{
		return "(" + x + ";" + y + ")";
	}
	public boolean sameAs (Point p)
	{
		return p.x == x && p.y == y;
	}
}
