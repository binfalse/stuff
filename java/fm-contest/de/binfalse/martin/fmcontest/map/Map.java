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
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Vector;
import java.util.Map.Entry;

import de.binfalse.martin.fmcontest.player.ItsMe;

public class Map implements Runnable
{
	private double [][] map;
	private int [][] player;
	private int [][] areas;
	private final double defTox = 0.01;
	private static int maxNum;
	private HashMap<Integer, Room> rooms;
	public static boolean threading = false;
	
	public Map ()
	{
		rooms = null;
		map = null;
		player = null;
		areas = null;
		maxNum = 0;
	}
	
	public boolean validPostion (Point p)
	{
		return map[p.y][p.x] >= 0;
	}
	
	/*
	 * is a disired movement valid!?
	 * 
	 * @param px x pos you are staying
	 * @param py y pos you are staying
	 * @param x x pos you want to move to ( must be in [px-1 .. px+1] )
	 * @param y y pos you want to move to ( must be in [py-1 .. py+1] )
	 */
	public boolean validMovement (int px, int py, int x, int y)
	{
		// target == wall ??
		if (map[y][x] < 0) return false;
		// vertical or horizontal movement ??
		if (x - px == 0 || y - py == 0) return true;
		// diagonal needs more checks
		if (map[py][x] >= 0 || map[y][px] >= 0) return true;
		return false;
	}
	
	public boolean readMap (String file)
	{
		if (isValidMapname (file))
		{
			Vector<String> v = new Vector<String> ();
			String strLine;
			
			try
			{
				BufferedReader br = new BufferedReader (new FileReader (new File (file)));
				while ((strLine = br.readLine()) != null) if (strLine.length () > 0) v.add (strLine);
				br.close ();
			}
			catch (IOException e)
			{
				e.printStackTrace ();
				return false;
			}
			
			map = new double [v.size ()][v.elementAt (0).length ()];
			player = new int [map.length][map[0].length];
			areas = new int [map.length][map[0].length];
			for (int i = 0; i < map.length; i++)
			{
				strLine = v.elementAt (i);
				for (int j = 0; j < map[i].length; j++)
				{
					if (strLine.charAt (j) == ' ') map[i][j] = defTox;
					else
					{
						map[i][j] = -1;
						areas[i][j] = -1;
					}
					player[i][j] = -1;
				}
			}
			new Thread (this).start ();
			
			String tox = file.substring (0, file.lastIndexOf ('.')) + ".toxic";
			File f = new File (tox);
			
			if (f.exists ())
			{
				try
				{
					BufferedReader br = new BufferedReader (new FileReader (f));
					int l = 0;
					while ((strLine = br.readLine()) != null)
					{
						if (strLine.length () > 0)
							for (int j = 0; j < map[l].length; j++)
							{
								if (map[l][j] < 0) continue;
								if (strLine.charAt (j) == ' ') map[l][j] = .01;
								else if (strLine.charAt (j) == '#' || strLine.charAt (j) == '0') map[l][j] = .2;
								else map[l][j] = 0.02 * Double.parseDouble ("" + strLine.charAt (j));
							}
						l++;
					}
					br.close ();
				}
				catch (IOException e)
				{
					e.printStackTrace ();
				}
			}
			return true;
		}
		else return false;
	}
	public boolean isValidMapname (String filename )
	{
		return ( filename.length () > 4 && filename.substring (filename.length () - 4).equals (".map"));
	}
	
	public void setToxic (int x, int y, double val)
	{
		map[y][x] = val;
	}
	public double[][] getMap ()
	{
		return map;
	}
	
	public double getToxic (int x, int y)
	{
		return map[y][x];
	}
	public double getToxic (Point p)
	{
		return map[p.y][p.x];
	}
	
	/*
	 * set players position
	 * 
	 * @param px previous x
	 * @param py previous y
	 * @param x new x
	 * @param y new y
	 * @param who the players ID
	 */
	public void setPlayer (int px, int py, int x, int y, int who)
	{
		if (px >= 0 && py >= 0 && px < player[0].length && py < player.length && player[py][px] == who) player[py][px] = -1;
		player[y][x] = who;
	}
	public int getPlayer (int x, int y)
	{
		return player[y][x];
	}
	
	public Point explore (DMap dm, Point p, Vector<Integer> stillExplored)
	{
		while (stillExplored.size () > rooms.size () - 1) stillExplored.remove (0);
		double [] dists = new double [rooms.size ()];
		int [] r = new int [rooms.size ()];
		double sum = 0;
		int i = 0;
		for (Entry<Integer, Room> entry : rooms.entrySet())
		{
			if (stillExplored.contains (entry.getKey ())) continue;
			dists[i] = dm.distTo (entry.getValue ().mid);
			r[i] = entry.getKey ();
			sum += dists[i++];
		}
		int max = i;
		for (i = 0; i < max; i++) dists[i] /= sum;
		
		double rand = ItsMe.rand.nextDouble ();
		sum = 0;
		for (i = 0; i < max; i++)
		{
			sum += dists[i];
			if (sum >= rand)
			{
				stillExplored.add (r[i]);
				return rooms.get (r[i]).mid;
			}
		}
		stillExplored.add (r[r.length - 1]);
		return rooms.get (r[r.length - 1]).mid;
	}
	
	public Point getOptimalHidePosition (DMap dm, Point p, Vector<Integer> friends)
	{
		//search for a pos not too far away, far away from mid
		double [] dists = new double [rooms.size ()];
		int [] r = new int [rooms.size ()];
		double sum = 0;
		int i = 0;
		for (Entry<Integer, Room> entry : rooms.entrySet())
		{
			dists[i] = dm.distTo (entry.getValue ().mid) - 3 * entry.getValue ().mid.dist (dm.map[0].length / 2, dm.map.length / 2);
			for (int f = 0; f < friends.size (); f++) dists[i] += p.dist (ItsMe.enemies.get (friends.get (f)).koord) / 10;
			r[i] = entry.getKey ();
			sum += dists[i++];
		}
		for (i = 0; i < dists.length; i++)
			dists[i] /= sum;
		
		double rand = ItsMe.rand.nextDouble ();
		
		sum = 0;
		for (i = 0; i < dists.length; i++)
		{
			sum += dists[i];
			if (sum >= rand) return rooms.get (r[i]).mid;
		}
		
		return rooms.get (r[0]).mid;
	}
	
	public int getRoomNumber (Point p)
	{
		return areas[p.y][p.x];
	}
	
	public int getRoomNumber (int x, int y)
	{
		return areas[y][x];
	}
	
	public Room getRoom (int number)
	{
		return rooms.get (number);
	}
	
	public Vector<Door> getDoors (Point p)
	{
		if (getRoomNumber (p) <= 0) p = findRoomNextTo (p);
		return rooms.get (getRoomNumber (p)).getNeigbors ();
	}
	
	public String toString ()
	{
		String s = "MAP:\n";
		for (int i = 0; i < map.length; i++)
		{
			for (int j = 0; j < map[i].length; j++) s += map[i][j] + "\t";
			s += "\n";
		}
		s += "\n\nAreas:\n";
		for (int i = 0; i < areas.length; i++)
		{
			for (int j = 0; j < areas[i].length; j++) s += areas[i][j] + "\t";
			s += "\n";
		}
		return s;
	}
	
	@Override
	public void run ()
	{
		threading = true;
		
		boolean closedMap = true;
		maxNum = 1;
		for (int i = 0; i < areas.length; i++)
			if (map[i][0] != -1 || map[i][map[0].length - 1] != -1)
			{
				closedMap = false;
				break;
			}
		if (closedMap)
			for (int i = 0; i < areas[0].length; i++)
				if (map[0][i] != -1 || map[areas.length - 1][i] != -1)
				{
					closedMap = false;
					break;
				}
		if (closedMap) split (1, 1, areas[0].length - 1, areas.length - 1);
		else split (0, 0, areas[0].length, areas.length);
		
		while (expandRooms ());
		collectRooms ();
		
		for (Entry<Integer, Room> entry : rooms.entrySet()) entry.getValue ().calcMid ();
		
		threading = false;
	}
	private void collectRooms ()
	{
		rooms = new HashMap<Integer, Room> ();
		
		for (int y = 0; y < areas.length; y++)
		{
			for (int x = 0; x < areas[y].length; x++)
			{
				if (areas[y][x] < 0) continue;
				else if (areas[y][x] > 0)
				{
					if (rooms.get (areas[y][x]) == null) rooms.put (areas[y][x], new Room ());
					rooms.get (areas[y][x]).addPoint (new Point (x, y));
					
					// is it also a door!?
					
					//left
					if (x > 0 && areas[y][x - 1] > 0 && areas[y][x - 1] != areas[y][x])
						rooms.get (areas[y][x]).addNeighbor (new Door (new Point (x - 1, y), areas[y][x - 1]));
					
					//right
					if (x < areas[y].length - 1 && areas[y][x + 1] > 0 && areas[y][x + 1] != areas[y][x])
						rooms.get (areas[y][x]).addNeighbor (new Door (new Point (x + 1, y), areas[y][x + 1]));
					
					//top
					if (y > 0 && areas[y - 1][x] > 0 && areas[y - 1][x] != areas[y][x])
						rooms.get (areas[y][x]).addNeighbor (new Door (new Point (x, y - 1), areas[y - 1][x]));
					
					//bottom
					if (y < areas.length - 1 && areas[y + 1][x] > 0 && areas[y + 1][x] != areas[y][x])
						rooms.get (areas[y][x]).addNeighbor (new Door (new Point (x, y + 1), areas[y + 1][x]));
				}
				else
				{
					// only door
					int [] arr = new int [4];
					arr[0] = x > 0 ? areas[y][x - 1] : -1;
					arr[1] = x < areas[y].length - 1 ? areas[y][x + 1] : -1;
					arr[2] = y > 0 ? areas[y - 1][x] : -1;
					arr[3] = y < areas.length - 1 ? areas[y + 1][x] : -1;
					for (int i = 0; i < 4; i++)
						for (int j = i + 1; j < 4; j++)
							if (arr[i] > 0 && arr[j] > 0 && arr[i] != arr[j])
							{
								if (rooms.get (arr[i]) == null) rooms.put (arr[i], new Room ());
								rooms.get (arr[i]).addNeighbor (new Door (new Point (x, y), arr[j]));
								if (rooms.get (arr[j]) == null) rooms.put (arr[j], new Room ());
								rooms.get (arr[j]).addNeighbor (new Door (new Point (x, y), arr[i]));
							}
				}
			}
		}
	}
	private boolean expandRooms ()
	{
		// don't work on original matrix, slower but prevents chainings
		int [][] prevAreas = new int [areas.length][areas[0].length];
		for (int y = 0; y < areas.length; y++)
			for (int x = 0; x < areas[y].length; x++)
				prevAreas[y][x] = areas[y][x];
		
		boolean smthChanged = false;
		
		// left, right, up, down, sum, max;
		int [] arr = new int [6];
		for (int y = 0; y < areas.length; y++)
		{
			for (int x = 0; x < areas[y].length; x++)
			{
				if (prevAreas[y][x] > 0 || map[y][x] < 0) continue;
				
				// collect neighbors
				arr[0] = x > 0 ? prevAreas[y][x - 1] : -1;
				arr[1] = x < prevAreas[y].length - 1 ? prevAreas[y][x + 1] : -1;
				arr[2] = y > 0 ? prevAreas[y - 1][x] : -1;
				arr[3] = y < prevAreas.length - 1 ? prevAreas[y + 1][x] : -1;
				// sum
				arr[4] = arr[0] + arr[1] + arr[2] + arr[3];
				// max
				arr[5] = arr[0];
				for (int i = 1; i < 4; i++)
					if (arr[5] < arr[i]) arr[5] = arr[i];
				
				// if max in neighbors <= 0 -> nothing to do
				if (arr[5] <= 0) continue;
				
				// are all pos. neighbors from same room?
				int common = 0;
				for (int i = 0; i < 4; i++)
				{
					if (common == 0 && arr[i] > 0) common = arr[i];
					if (common > 0 && arr[i] > 0 && common != arr[i]) common = -1;
				}
				
				// all neighbors from same room
				if (common > 0)
				{
					// only one neighbor
					areas[y][x] = common;
					smthChanged = true;
				}
				//otherwise no -> here we find a door later (actually cannot decide how to assign)
			}
		}
		return smthChanged;
	}
	private void split (int startx, int starty, int endx, int endy)
	{
		if ((endx - startx) * (endy - starty) < 5)
		{
			return;
		}
		boolean intersect = false;
		for (int y = starty; y < endy; y++)
			for (int x = startx; x < endx && !intersect; x++)
				if (map[y][x] < 0)
				{
					intersect = true;
					break;
				}
		
		if (intersect)
		{
			int midx = startx + (endx - startx) / 2;
			int midy = starty + (endy - starty) / 2;
			split (startx, starty, midx, midy);
			split (midx, starty, endx, midy);
			split (startx, midy, midx, endy);
			split (midx, midy, endx, endy);
		}
		else
		{
			int we = maxNum++;
			for (int y = starty; y < endy; y++)
				for (int x = startx; x < endx && !intersect; x++)
					areas[y][x] = we;
			
			//try to join to left
			if (startx > 0)
			{
				int base = areas[starty][startx - 1];
				if (base > 0)
				{
					boolean join = true;
					for (int i = starty; i < endy; i++)
						if (areas[i][startx - 1] != base)
						{
							join = false;
							break;
						}
					if (join) replaceAreas (base, we, startx - 1, starty);
				}
			}
			//try to join to right
			if (endx < areas[0].length - 1)
			{
				int base = areas[starty][endx + 1];
				if (base > 0)
				{
					boolean join = true;
					for (int i = starty; i < endy; i++)
						if (areas[i][endx + 1] != base)
						{
							join = false;
							break;
						}
					if (join) replaceAreas (base, we, endx + 1, starty);
				}
			}
			//try to join to top
			if (starty > 0)
			{
				int base = areas[starty - 1][startx];
				if (base > 0)
				{
					boolean join = true;
					for (int i = startx; i < endx; i++)
						if (areas[starty - 1][i] != base)
						{
							join = false;
							break;
						}
					if (join) replaceAreas (base, we, startx, starty - 1);
				}
			}
			//try to join to bottom
			if (endy < areas.length - 1)
			{
				int base = areas[endy + 1][startx];
				if (base > 0)
				{
					boolean join = true;
					for (int i = startx; i < endx; i++)
						if (areas[endy + 1][i] != base)
						{
							join = false;
							break;
						}
					if (join) replaceAreas (base, we, startx, endy + 1);
				}
			}
		}
	}
	private void replaceAreas (int before, int now, int x, int y)
	{
		if (before == now) return;
		if (x > 0 && areas[y][x - 1] == before)
		{
			areas[y][x - 1] = now;
			replaceAreas(before, now, x - 1, y);
		}
		if (x < areas[0].length - 1 && areas[y][x + 1] == before)
		{
			areas[y][x + 1] = now;
			replaceAreas(before, now, x + 1, y);
		}
		if (y > 0 && areas[y - 1][x] == before)
		{
			areas[y - 1][x] = now;
			replaceAreas(before, now, x, y - 1);
		}
		if (y < areas.length - 1 && areas[y + 1][x] == before)
		{
			areas[y + 1][x] = now;
			replaceAreas(before, now, x, y + 1);
		}
	}
	
	public Point getNeighbor (Point r, Vector<Integer> friends)
	{
		// actual random door
		if (areas[r.y][r.x] <= 0) r = findRoomNextTo (r);
		Room room = rooms.get (areas[r.y][r.x]);
		Vector<Door> doors = room.getNeigbors ();
		int d = ItsMe.rand.nextInt (doors.size ());
		
		return rooms.get (doors.elementAt (d).neighbor).mid;
	}
	public Point findRoomNextTo (Point r)
	{
		int x = r.x, y = r.y;
		
		while (areas[y][x] <= 0)
		{
			x += (ItsMe.rand.nextInt () % 2) - 1;
			y += (ItsMe.rand.nextInt () % 2) - 1;
			if (x < 0) x += 5;
			if (y < 0) y += 5;
			if (x >= areas[0].length) x -= 5;
			if (y >= areas.length) y -= 5;
		}
		return new Point (x, y);
	}
}
