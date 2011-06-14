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
package de.binfalse.martin.fmcontest;

/**
 * @author Martin Scharm
 */
public class Statics
{
	public static final int NONE = -1;
	public static final int NORTH = 0;
	public static final int NORTH_EAST = 1;
	public static final int EAST = 2;
	public static final int SOUTH_EAST = 3;
	public static final int SOUTH = 4;
	public static final int SOUTH_WEST = 5;
	public static final int WEST = 6;
	public static final int NORTH_WEST = 7;
	
	public static int resolvDir (String s)
	{
		if (s.equals ("NORTH_EAST")) return NORTH_EAST;
		if (s.equals ("NORTH")) return NORTH;
		if (s.equals ("NORTH_WEST")) return NORTH_WEST;
		if (s.equals ("WEST")) return WEST;
		if (s.equals ("SOUTH_WEST")) return SOUTH_WEST;
		if (s.equals ("SOUTH")) return SOUTH;
		if (s.equals ("SOUTH_EAST")) return SOUTH_EAST;
		if (s.equals ("EAST")) return EAST;
		return 0;
		
	}
	public static String resolvDir (int i)
	{
		switch (i)
		{
			case NORTH: return "NORTH";
			case NORTH_EAST: return "NORTH_EAST";
			case EAST: return "EAST";
			case SOUTH_EAST: return "SOUTH_EAST";
			case SOUTH: return "SOUTH";
			case SOUTH_WEST: return "SOUTH_WEST";
			case WEST: return "WEST";
			case NORTH_WEST: return "NORTH_WEST";
			default: return "NONE";
		}
	}
	
	public static int nextLook (int look)
	{
		return (look + 3) % 8;
	}
	
	public static int getDir (int x, int y)
	{
		if (x == 0)
		{
			if (y < 0) return SOUTH;
			if (y > 0) return NORTH;
		}
		if (x > 0)
		{
			if (y < 0) return SOUTH_WEST;
			if (y > 0) return NORTH_WEST;
		}
		if (x < 0)
		{
			if (y < 0) return SOUTH_EAST;
			if (y > 0) return NORTH_EAST;
		}
		if (y == 0)
		{
			if (x > 0) return WEST;
			if (x < 0) return EAST;
		}
		return NONE;
	}
}
