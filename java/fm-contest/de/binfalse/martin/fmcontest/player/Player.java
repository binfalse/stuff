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

import de.binfalse.martin.fmcontest.map.DMap;
import de.binfalse.martin.fmcontest.map.Map;
import de.binfalse.martin.fmcontest.map.Point;

/**
 * @author Martin Scharm
 */
public class Player
{
	public int number, px, py, look, last_seen;
	public double health;
	public boolean human;
	public DMap map;
	public Point [] motionbProfile;
	public Point koord;
	public int numSeen;
	
	public Player ()
	{
		number = px = py = look = -1;
		health = 100;
		human = true;
		last_seen = 0;
		map = null;
		motionbProfile = new Point [100];
		koord = new Point ();
		numSeen = 0;
	}
	public Player (Map m, int number, int px, int py, int round, int look)
	{
		map = new DMap (m);
		this.number = number;
		this.px = px;
		this.py = py;
		last_seen = round;
		this.look = look;
		human = true;
		health = 100;
		motionbProfile = new Point [100];
		koord = new Point (px, py);
		numSeen = 0;
	}
	public void setMap (Map m)
	{
		map = new DMap (m);
	}
	public void setNumber (int number)
	{
		this.number = number;		
	}
	public void setPosition (int px, int py, int round, Map orgMap)
	{
		if (round >= motionbProfile.length - 1) reAdjustMotionProfile (round);
		motionbProfile[round] = new Point (px, py);
		
		numSeen++;
		last_seen = round;
		this.px = px;
		this.py = py;
		if (map == null) map = new DMap (orgMap);
		map.redist (px, py, orgMap);
		koord.x = px;
		koord.y = py;
		
	}
	public void setLook (int look)
	{
		this.look = look;
	}
	public void setHealth (int health)
	{
		this.health = health;
	}
	
	private void reAdjustMotionProfile (int round)
	{
		Point [] newMotionbProfile = new Point [round * 2];
		for (int i = 0; i < motionbProfile.length; i++) newMotionbProfile[i] = motionbProfile[i];
		motionbProfile = newMotionbProfile;
	}
	public double moveVariance ()
	{
		double x = 0, y = 0, variance = 0;
		for (int i = 0; i < motionbProfile.length; i++)
		{
			if (motionbProfile[i] == null) continue;
			x += motionbProfile[i].x;
			y += motionbProfile[i].y;
		}
		x /= (double) numSeen;
		y /= (double) numSeen;
		
		for (int i = 0; i < motionbProfile.length; i++)
		{
			if (motionbProfile[i] == null) continue;
			variance += (motionbProfile[i].x - x) * (motionbProfile[i].y - y);
		}
		
		return variance / (double) numSeen;
	}
	public Point predictCoord ()
	{
		if (numSeen == 1) return koord;
		return koord;
	}
}
