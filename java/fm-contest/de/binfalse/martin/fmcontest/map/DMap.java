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

import java.util.ArrayList;
import java.util.Vector;

import de.binfalse.martin.fmcontest.Statics;
import de.binfalse.martin.fmcontest.player.ItsMe;

/**
 * @author Martin Scharm
 */
public class DMap
{
	public double [][] map;
	private Vector<Integer> playerDist;
	
	public DMap ()
	{
		map = null;
		playerDist = new Vector<Integer> ();
	}
	public DMap (Map m)
	{
		playerDist = new Vector<Integer> ();
		double [][] orgMap = m.getMap ();
		map = new double [orgMap.length][orgMap[0].length];
		for (int i = 0; i < map.length; i++)
		{
			for (int j = 0; j < map[i].length; j++)
			{
				if (orgMap[i][j] < 0) map[i][j] = -1;
				else map[i][j] = Integer.MAX_VALUE;
			}
		}
	}
	public void setMap (Map m)
	{
		double [][] orgMap = m.getMap ();
		map = new double [orgMap.length][orgMap[0].length];
		for (int i = 0; i < map.length; i++)
		{
			for (int j = 0; j < map[i].length; j++)
			{
				if (orgMap[i][j] < 0) map[i][j] = -1;
				else map[i][j] = Double.MAX_VALUE;
			}
		}
	}
	public void redist (int px, int py, Map orgMap)
	{
		playerDist = new Vector<Integer> ();
		for (int i = 0; i < map.length; i++)
		{
			for (int j = 0; j < map[i].length; j++)
			{
				if (map[i][j] >= 0) map[i][j] = Integer.MAX_VALUE;
			}
		}
		
		ArrayList<Point> q = new ArrayList<Point> ();
		map[py][px] = 0;
		q.add (new Point (px, py));
		
		while (q.size () > 0)
		{
			Point p = q.remove (0);
			if (orgMap.getPlayer (p.x, p.y) >= 0)
			{
				playerDist.add (orgMap.getPlayer (p.x, p.y) );
			}
			// NB 4
			if (p.x + 1 < map[0].length && map[p.y][p.x + 1] >= 0 && map[p.y][p.x + 1] > map[p.y][p.x] + 1)
			{
				map[p.y][p.x + 1] = map[p.y][p.x] + 1;
				q.add (new Point (p.x + 1, p.y));
			}
			if (p.x - 1 >= 0 && map[p.y][p.x - 1] >= 0 && map[p.y][p.x - 1] > map[p.y][p.x] + 1)
			{
				map[p.y][p.x - 1] = map[p.y][p.x] + 1;
				q.add (new Point (p.x - 1, p.y));
			}
			if (p.y + 1 < map.length && map[p.y + 1][p.x] >= 0 && map[p.y + 1][p.x] > map[p.y][p.x] + 1)
			{
				map[p.y + 1][p.x] = map[p.y][p.x] + 1;
				q.add (new Point (p.x, p.y + 1));
			}
			if (p.y - 1 >= 0 && map[p.y - 1][p.x] >= 0 && map[p.y - 1][p.x] > map[p.y][p.x] + 1)
			{
				map[p.y - 1][p.x] = map[p.y][p.x] + 1;
				q.add (new Point (p.x, p.y - 1));
			}
			
			// NB 8
			if (p.y - 1 >= 0 && p.x + 1 < map[0].length && map[p.y - 1][p.x + 1] >= 0 && map[p.y - 1][p.x] >= 0 && map[p.y][p.x + 1] >= 0 && map[p.y - 1][p.x + 1] > map[p.y][p.x] + Math.sqrt (2))
			{
				map[p.y - 1][p.x + 1] = map[p.y][p.x] + Math.sqrt (2);
				q.add (new Point (p.x + 1, p.y - 1));
			}
			if (p.y - 1 >= 0 && p.x - 1 > 0 && map[p.y - 1][p.x - 1] >= 0 && map[p.y][p.x - 1] >= 0 && map[p.y - 1][p.x] >= 0 && map[p.y - 1][p.x - 1] > map[p.y][p.x] + Math.sqrt (2))
			{
				map[p.y - 1][p.x - 1] = map[p.y][p.x] + Math.sqrt (2);
				q.add (new Point (p.x - 1, p.y - 1));
			}
			if (p.y + 1 < map.length && p.x + 1 < map[0].length && map[p.y + 1][p.x + 1] >= 0 && map[p.y][p.x + 1] >= 0 && map[p.y + 1][p.x] >= 0 && map[p.y + 1][p.x + 1] > map[p.y][p.x] + Math.sqrt (2))
			{
				map[p.y + 1][p.x + 1] = map[p.y][p.x] + Math.sqrt (2);
				q.add (new Point (p.x + 1, p.y + 1));
			}
			if (p.y + 1 < map.length  && p.x - 1 > 0 && map[p.y + 1][p.x - 1] >= 0 && map[p.y][p.x - 1] >= 0 && map[p.y + 1][p.x] >= 0 && map[p.y + 1][p.x - 1] > map[p.y][p.x] + Math.sqrt (2))
			{
				map[p.y + 1][p.x - 1] = map[p.y][p.x] + Math.sqrt (2);
				q.add (new Point (p.x - 1, p.y + 1));
			}
		}
	}
	
	public double [][] copyMap ()
	{
		double [][] cpy = new double [map.length][map[0].length];
		
		for (int i = 0; i < map.length; i++)
			for (int j = 0; j < map[i].length; j++)
				cpy[i][j] = map[i][j];
		return cpy;
	}
	
	public String toString ()
	{
		String s = "";
		for (int i = 0; i < map.length; i++)
		{
			for (int j = 0; j < map[i].length; j++)
				s += map[i][j] + '\t';
			s += "\n";
		}
		return s;
	}
	
	public double distTo (int x, int y)
	{
		return map[y][x];
	}
	public double distTo (Point p)
	{
		return map[p.y][p.x];
	}
	
	/*
	 * fastest way to any position
	 * 
	 * @param x x koord of target
	 * @param y y koord of target
	 * 
	 * @return Statics.direction
	 */
	public int dirTo (int x, int y, Map orgMap)
	{
		int breakout = 0;
		double minDist = Double.MAX_VALUE;
		while (breakout++ < 10000)
		{
			int minI = 1, minJ = 1;
			minDist = Double.MAX_VALUE;
			for (int i = -1; i < 2; i++)
			{
				for (int j = -1; j < 2; j++)
				{
					if (x + i < 0 || x + i >= map[0].length || y + j < 0 || y + j >= map.length) continue;
					if (map[y + j][x + i] < 0 || map[y][x + i] < 0 || map[y + j][x] < 0 || orgMap.getPlayer (x + i, y + j) >= 0 || orgMap.getPlayer (x, y + j) >= 0 || orgMap.getPlayer (x + i, y) >= 0) continue;
					if (map[y + j][x + i] < 1)
						return Statics.getDir (i, j);
					if (map[y + j][x + i] < minDist)
					{
						minDist = map[y + j][x + i];
						minI = i;
						minJ = j;
					}
				}
			}
			x += minI;
			y += minJ;
		}
		return Statics.getDir (ItsMe.rand.nextInt (2) - 1, ItsMe.rand.nextInt (2) - 1);
	}
	/*
	 * fastest way to any position
	 * 
	 * @param p Point of target
	 * 
	 * @return Statics.direction
	 */
	public int dirTo (Point p, Map orgMap)
	{
		return dirTo (p.x, p.y, orgMap);
	}
}
