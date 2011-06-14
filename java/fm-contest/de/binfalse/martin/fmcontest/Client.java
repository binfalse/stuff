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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.HashMap;
import java.util.Map.Entry;

import de.binfalse.martin.fmcontest.map.Map;
import de.binfalse.martin.fmcontest.player.ItsMe;
import de.binfalse.martin.fmcontest.player.Player;

/**
 * @author Martin Scharm
 */
public class Client
{
	private static Socket socket;
	private static PrintWriter sockWriter;
	private static BufferedReader sockReader;
	private String sockMsg;
	
	private boolean die;
	private int roundNum;
	
	ItsMe me;
	Map map;
	
	public Client (String server, int port) throws IOException
	{
		sockMsg = "";
		socket = new Socket(server, port);
		sockWriter = new PrintWriter (new OutputStreamWriter (socket.getOutputStream ()));
		sockReader = new BufferedReader (new InputStreamReader (socket.getInputStream ()));
		die = false;
		roundNum = 0;
		me = new ItsMe ();
		ItsMe.enemies = new HashMap<Integer, Player> ();
		map = new Map ();
	}
	
	public static void send (String msg)
	{
		sockWriter.print (msg + "|");
		sockWriter.flush ();
	}
	
	private void processMsg ()
	{
		int pos = sockMsg.indexOf ('|');
		while (pos > 0 && sockMsg.length () > 0)
		{
			String msg = sockMsg.substring (0, pos);
			sockMsg = sockMsg.substring (pos + 1);
			if (msg.length () > 0) react (msg.replaceAll (",", " ").split (" "));
			pos = sockMsg.indexOf ('|');
		}
	}
	
	public void listen ()
	{
		while (!die)
		{
			try
			{
				char [] cbuf = new char [1024];
				int anzahlZeichen = sockReader.read (cbuf, 0, 1024);
				sockMsg += new String (cbuf, 0, anzahlZeichen);
				processMsg ();
			}
			catch (IOException e)
			{
				e.printStackTrace();
			}
		}
	}
	
	private void react (String [] msg)
	{
		switch (msg.length)
		{
			// PING | DISCONNECT
			case 1:
				if (msg[0].equals ("DISCONNECT"))
				{
					die = true;
					return;
				}
				break;
				// ID <NUMMER> | CONNECTED <NUMMER> | DISCONNECTED <NUMMER> | MAP <MAPNAME> | START <RUNDE>
			case 2:
				if (msg[0].equals ("START"))
				{
					roundNum = Integer.parseInt (msg[1]);
					ItsMe.globalMap = map;
					ItsMe.RoundNum = roundNum;
					me.run ();
					ItsMe.stopRun = true;
					send ("MOVE " + Statics.resolvDir (ItsMe.willGo) + " " + Statics.resolvDir (ItsMe.willLook));
					return;
				}
				if (msg[0].equals ("ID"))
				{
					int player = Integer.parseInt (msg[1]);
					me.setNumber (player);
					send ("ID_OKAY");
					return;
				}
				if (msg[0].equals ("DISCONNECTED"))
				{
					int who = Integer.parseInt (msg[1]);
					ItsMe.enemies.remove (who);
					return;
				}
				if (msg[0].equals ("MAP"))
				{
					map.readMap (msg[1]);
					for (Entry<Integer, Player> entry : ItsMe.enemies.entrySet()) entry.getValue ().setMap (map);
					return;
				}
				break;
				// LIFE <WERT> <NUMMER> | TEAMCHANGE <TEAM> <NUMMER> | 
			case 3:
				if (msg[0].equals ("LIFE"))
				{
					int who = Integer.parseInt (msg[2]);
					double live = Double.parseDouble (msg[1]);
					if (who == me.number) me.health = live;
					else
					{
						if (ItsMe.enemies.get (who) == null) ItsMe.enemies.put (who, new Player ());
						ItsMe.enemies.get (who).health = live;
					}
					return;
				}
				if (msg[0].equals ("TEAMCHANGE"))
				{
					int who = Integer.parseInt (msg[2]);
					if (who == me.number)
					{
						me.human = msg[1].equals ("BLUE");
						ItsMe.goTo = null;
					}
					else
					{
						ItsMe.TeamChangeLastRound = true;
						if (ItsMe.enemies.get (who) == null) ItsMe.enemies.put (who, new Player ());
						ItsMe.enemies.get (who).human = msg[1].equals ("BLUE");
					}
					return;
				}
				break;
				// TOXIC <X,Y> <WERT> | SET <X,Y> <VIEW> | 
			case 4:
				if (msg[0].equals ("TOXIC"))
				{
					int x = Integer.parseInt (msg[1]);
					int y = Integer.parseInt (msg[2]);
					double tox = Double.parseDouble (msg[3]);
					map.setToxic (x, y, tox);
					return;
				}
				if (msg[0].equals ("SET"))
				{
					int x = Integer.parseInt (msg[1]);
					int y = Integer.parseInt (msg[2]);
					me.setPosition (x, y, roundNum, map);
					me.look = Statics.resolvDir (msg[3]);
					return;
				}
				break;
				//SEE_PLAYER <X,Y> <VIEW> <NUMMER>
			case 5:
				if (msg[0].equals ("SEE_PLAYER"))
				{
					int x = Integer.parseInt (msg[1]);
					int y = Integer.parseInt (msg[2]);
					int who = Integer.parseInt (msg[4]);
					if (ItsMe.enemies.get (who) == null) ItsMe.enemies.put (who, new Player ());
					Player p = ItsMe.enemies.get (who);
					map.setPlayer (p.px, p.py, x, y, who);
					p.setPosition (x, y, roundNum, map);
					p.look = Statics.resolvDir (msg[3]);
					me.canSee (who);
					return;
				}
				break;
		}
		
	}
	
	public static void main (String[] args)
	{
		String server = "localhost";
		int port = 15000;
		if (args.length == 2)
		{
			server = args[0];
			port = Integer.parseInt (args[1]);
		}
		try
		{
			Client winner = new Client (server, port);
			winner.listen ();
		}
		catch (IOException e)
		{
			e.printStackTrace();
		}
	}
}
