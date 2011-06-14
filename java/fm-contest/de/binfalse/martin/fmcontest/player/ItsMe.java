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
package de.binfalse.martin.fmcontest.player;

import java.util.HashMap;
import java.util.Random;
import java.util.Vector;
import java.util.Map.Entry;

import de.binfalse.martin.fmcontest.Statics;
import de.binfalse.martin.fmcontest.map.Door;
import de.binfalse.martin.fmcontest.map.Map;
import de.binfalse.martin.fmcontest.map.Point;
import de.binfalse.martin.fmcontest.map.Room;


/**
 * ItsMe
 * 
 * represents an more or less intelligent player
 * 
 * @author Martin Scharm
 */
public class ItsMe extends Player
{
	
	public static int target = -1;
	public static int lastRoomChange = 0;
	public static Random rand = new Random ();
	public static HashMap<Integer, Player> enemies;
	public static Map globalMap;
	public static boolean running;
	public static boolean stopRun;
	public static int willLook;
	public static int willGo;
	public static Point goTo;
	public static boolean TeamChangeLastRound = false;
	public static int RoundNum = 0;
	private static Vector<Integer> failed = new Vector<Integer> ();
	public static Vector<Integer> stillExplored = new Vector<Integer> ();
	
	private Vector<Integer> seeEnemies = new Vector<Integer> (), seeFriends = new Vector<Integer> ();
	
	public ItsMe ()
	{
		super ();
		goTo = null;
	}
	
	public void canSee (int who)
	{
		if (enemies.get (who).human == human)
		{
			if (!seeFriends.contains (who)) seeFriends.add (who);
		}
		else
		{
			if (!seeEnemies.contains (who)) seeEnemies.add (who);
		}
	}
	
	private void predator ()
	{
		double score = Double.NEGATIVE_INFINITY;
		int enemy = 0;
		
		if (seeEnemies.size () > 0) willGo = map.dirTo (enemies.get (seeEnemies.elementAt (0)).koord, globalMap);
		
		// can i see someone ?? is someone else faster than me ??
		for (int i = 0; i < seeEnemies.size () && !stopRun; i++)
		{
			double mydist = map.distTo (enemies.get (seeEnemies.elementAt (i)).koord);
			double minFriendDist = Double.MAX_VALUE;
			for (int j = 0; j < seeFriends.size (); j++)
			{
				double d = enemies.get (seeFriends.elementAt (j)).map.distTo (enemies.get (seeEnemies.elementAt (i)).koord);
				if (d < minFriendDist) minFriendDist = d;
			}
			double s = 120 - mydist + minFriendDist;
			if (s > score)
			{
				score = s;
				enemy = i;
			}
		}
		if (seeEnemies.size () > 0)
		{
			goTo = enemies.get (seeEnemies.elementAt (enemy)).koord;
			target = seeEnemies.elementAt (enemy);
			willGo = map.dirTo (goTo, globalMap);
			return;
		}
		
		
		// explore the map
		if (!Map.threading)
		{
			if(goTo == null || map.distTo (goTo) < 2)
			{
				if (target >= 0) failed.add (target);
				target = -1;
				goTo = predatorExplore ();
			}
			willGo = map.dirTo (goTo, globalMap);
			return;
		}
	}
	
	private Point predatorExplore ()
	{
		double score = -50;
		int player = -1;
		for (Entry<Integer, Player> entry : enemies.entrySet())
		{
			Player p = entry.getValue ();
			if (map.distTo (p.koord) < 5) continue;
			if (failed.contains (entry.getKey ())) continue;
			double s = 50 - (RoundNum - p.last_seen) - map.distTo (p.koord) - p.moveVariance ();
			if (s > score)
			{
				score = s;
				player = entry.getKey ();
			}
		}
		target = player;
		if (player < 0) return globalMap.explore (map, koord, stillExplored);
		else return enemies.get (player).predictCoord ();
	}
	
	private void prey ()
	{
		double score = 0;
		
		// does an enemy see me?
		if (seeEnemies.size () > 0)
		{
			double bestPosDist = 0;
			Point bestPos = null;
			
			// ersma versuchen alle tueren zu probieren -> raum möglichst verlassen
			if (globalMap.getRoomNumber (koord) > 0)
			{
				Vector<Door> doors = globalMap.getDoors (koord);
				for (int i = 0; i < doors.size (); i++)
				{
					double d = 0;
					double fastestEnemy = Double.MAX_VALUE;
					Point koord = doors.elementAt (i).koord;
					for (int j = 0; j < seeEnemies.size (); j++)
					{
						d = enemies.get (seeEnemies.elementAt (j)).map.distTo (koord);
						if (d < fastestEnemy) fastestEnemy = d;
					}
					d = map.distTo (koord);
					if (bestPosDist < fastestEnemy - d)
					{
						bestPos = globalMap.getRoom (doors.elementAt (i).neighbor).mid;
						bestPosDist = fastestEnemy - d;
					}
				}
			}
			
			if (bestPos == null)
			{
				bestPos = new Point ();
				bestPosDist = 0;
				
				double [][] shortMap = new double [map.map.length][map.map[0].length];
				for (int y = 0; y < shortMap.length; y++) for (int x = 0; x < shortMap[y].length; x++)
					shortMap[y][x] = Double.MAX_VALUE;
				
				// check full map for best position
				for (int j = 0; j < seeEnemies.size () && !stopRun; j++)
				{
					double [][] theirMap = enemies.get (seeEnemies.elementAt (j)).map.map;
					for (int y = 0; y < theirMap.length; y++) for (int x = 0; x < theirMap[y].length; x++) if (shortMap[y][x] > theirMap[y][x]) shortMap[y][x] = theirMap[y][x];
				}
				
				double [][] myMap = map.copyMap ();
				for (int y = 0; y < myMap.length; y++) for (int x = 0; x < myMap[y].length; x++)
				{
					if (shortMap[y][x] - myMap[y][x] > bestPosDist)
					{
						bestPosDist = shortMap[y][x] - myMap[y][x];
						bestPos.x = x;
						bestPos.y = y;
					}
				}
			}
			
			willGo = map.dirTo (bestPos.x, bestPos.y, globalMap);
			goTo = bestPos;
			lastRoomChange = RoundNum;
			return;
		}
		else
		{
			// nobody in near
			if (!Map.threading)
			{
				if(goTo == null)
				{
					goTo = globalMap.getOptimalHidePosition (map, koord, seeFriends);
					lastRoomChange = RoundNum;
				}
				if (TeamChangeLastRound || RoundNum - lastRoomChange > 20)
				{
					TeamChangeLastRound = false;
					goTo = globalMap.getNeighbor (koord, seeFriends);
					lastRoomChange = RoundNum;
				}
				
				int myroom = globalMap.getRoomNumber (goTo);
				if (myroom <= 0) myroom = globalMap.getRoomNumber (globalMap.findRoomNextTo (goTo));
				if (globalMap.getRoomNumber (koord) == myroom)
				{
					// hang out - keep doors in mind, try to avoid toxic
					Room home = globalMap.getRoom (myroom);
					Vector<Point> points = home.getPoints ();
					Vector<Door> doors = home.getNeigbors ();
					
					score = Double.NEGATIVE_INFINITY;
					int bestPoint = 0;
					
					for (int i = 0; i < points.size (); i++)
					{
						if (koord.sameAs (points.elementAt (i))) continue;
						double s = 0;
						for (int j = 0; j < doors.size (); j++) s += Math.pow(Math.abs (doors.elementAt (j).koord.x - points.elementAt (i).x) -  Math.abs (doors.elementAt (j).koord.y - points.elementAt (i).y), 2);
						s -= 3 * globalMap.getToxic (points.elementAt (i));
						if (s > score)
						{
							score = s;
							bestPoint = i;
						}
					}
					willGo = map.dirTo (points.elementAt (bestPoint), globalMap);
					return;
				}
				else
				{
					lastRoomChange = RoundNum;
					willGo = map.dirTo (goTo, globalMap);
					return;
				}
			}
			else
			{
				int x = 0, y = 1;
				double tox = 1000;
				for (int i = -1; i < 2; i++) for (int j = -1; j < 2; j++)
					if (globalMap.validMovement (px, py, px + i, py + j))
					{
						if (globalMap.getToxic (px + i, py + j) < tox)
						{
							tox = globalMap.getToxic (px + i, py + j);
							x = i;
							y = j;
						}
					}
				willGo = Statics.getDir (-x, -y);
			}
		}
	}
	
	public void run ()
	{
		running = true;
		stopRun = false;
		willLook = Statics.nextLook (look);
		willGo = Statics.NORTH;
		
		for (int i = seeEnemies.size () - 1; i >= 0; i--)
		{
			if (enemies.get (seeEnemies.elementAt (i)) == null)
			{
				seeEnemies.remove (i);
				continue;
			}
			if (enemies.get (seeEnemies.elementAt (i)).last_seen < RoundNum - 4)
			{
				seeEnemies.remove (i);
				continue;
			}
			if (enemies.get (seeEnemies.elementAt (i)).human == human)
			{
				seeFriends.add (seeEnemies.elementAt (i));
				seeEnemies.remove (i);
			}
		}
		
		for (int i = seeFriends.size () - 1; i >= 0; i--)
		{
			if (enemies.get (seeFriends.elementAt (i)) == null)
			{
				seeFriends.remove (i);
				continue;
			}
			if (enemies.get (seeFriends.elementAt (i)).last_seen < RoundNum - 4)
			{
				seeFriends.remove (i);
				continue;
			}
			if (enemies.get (seeFriends.elementAt (i)).human != human)
			{
				seeEnemies.add (seeFriends.elementAt (i));
				seeFriends.remove (i);
			}
		}
		
		sortFirends ();
		sortEnemies ();
		
		if (human) prey ();
		else predator ();
		
		TeamChangeLastRound = false;
		running = false;
	}
	
	private void sortFirends ()
	{
		for (int i = 0; i < seeFriends.size (); i++) for (int j = i; j < seeFriends.size (); j++)
		{
			if (map.distTo (enemies.get (seeFriends.elementAt (i)).koord) > map.distTo (enemies.get (seeFriends.elementAt (j)).koord))
			{
				int k = seeFriends.elementAt (j);
				seeFriends.set (j, seeFriends.elementAt (i));
				seeFriends.set (i, k);
			}
		}
	}
	
	private void sortEnemies ()
	{
		for (int i = 0; i < seeEnemies.size (); i++) for (int j = i; j < seeEnemies.size (); j++)
		{
			if (map.distTo (enemies.get (seeEnemies.elementAt (i)).koord) > map.distTo (enemies.get (seeEnemies.elementAt (j)).koord))
			{
				int k = seeEnemies.elementAt (j);
				seeEnemies.set (j, seeEnemies.elementAt (i));
				seeEnemies.set (i, k);
			}
		}
	}
}
