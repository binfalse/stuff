package de.binfalse.martin.x;

import java.awt.Color;
import java.awt.event.MouseEvent;

/**
* Link
* 
* this class creates a Link extending JLabel
* 
* @author Martin Scharm
*
*/
public class Link extends javax.swing.JLabel implements java.awt.event.MouseListener
{
	private String url;
	
	public Link ()
	{
		super ();
		init ("");
	}
	
	public Link (javax.swing.Icon image)
	{
		super (image);
		init ("");
	}
	
	public Link (javax.swing.Icon image, int horizontalAlignment)
	{
		super (image, horizontalAlignment);
		init ("");
	}
	
	public Link (String text)
	{
		super (text);
		init (text);
	}
	
	public Link (String text, javax.swing.Icon icon, int horizontalAlignment)
	{
		super (text, icon, horizontalAlignment);
		init (text);
	}
	
	
	public void setURL (String url)
	{
		this.url = url;
		this.setToolTipText ("Open " + url + " in your browser");
	}
	
	private void init (String url)
	{
		setURL (url);
		this.addMouseListener (this);
		this.setForeground (Color.BLUE);
	}
	
	public Link (String text, int horizontalAlignment)
	{
		super (text, horizontalAlignment);
		init (text);
	}
	
	@Override
	public void mouseClicked (MouseEvent arg0)
	{
		browse ();
	}
	@Override
	public void mouseEntered (MouseEvent arg0)
	{
		setCursor (new Cursor (Cursor.HAND_CURSOR));
	}
	@Override
	public void mouseExited (MouseEvent arg0)
	{
		setCursor (new Cursor (Cursor.DEFAULT_CURSOR));
	}
	@Override
	public void mousePressed (MouseEvent arg0) {}
	@Override
	public void mouseReleased (MouseEvent arg0) {}
	
	private void browse ()
	{
		if (java.awt.Desktop.isDesktopSupported ())
		{
			java.awt.Desktop desktop = java.awt.Desktop.getDesktop ();
			if (desktop.isSupported (java.awt.Desktop.Action.BROWSE))
			{
				try
				{
					desktop.browse (new java.net.URI (url));
					return;
				}
				catch (java.io.IOException e)
				{
					e.printStackTrace ();
				}
				catch (java.net.URISyntaxException e)
				{
					e.printStackTrace ();
				}
			}
		}
		
		
		String osName = System.getProperty("os.name");
		try
		{
			if (osName.startsWith ("Windows"))
			{
				Runtime.getRuntime ().exec ("rundll32 url.dll,FileProtocolHandler " + url);
			}
			else if (osName.startsWith ("Mac OS"))
			{
				Class fileMgr = Class.forName ("com.apple.eio.FileManager");
				java.lang.reflect.Method openURL = fileMgr.getDeclaredMethod ("openURL", new Class[] {String.class});
				openURL.invoke (null, new Object[] {url});
			} 
			else
			{
				//check for $BROWSER
				java.util.Map<String, String> env = System.getenv ();
				if (env.get ("BROWSER") != null)
				{
					Runtime.getRuntime ().exec (env.get ("BROWSER") + " " + url);
					return;
				}
				
				//check for common browsers
				String[] browsers = { "firefox", "iceweasel", "chrome", "opera", "konqueror", "epiphany", "mozilla", "netscape" };
				String browser = null;
				for (int count = 0; count < browsers.length && browser == null; count++)
					if (Runtime.getRuntime ().exec (new String[] {"which", browsers[count]}).waitFor () == 0)
					{
						browser = browsers[count];
						break;
					}
					if (browser == null)
						throw new RuntimeException ("couldn't find any browser...");
					else
						Runtime.getRuntime ().exec (new String[] {browser, url});
			}
		}
		catch (Exception e)
		{
			javax.swing.JOptionPane.showMessageDialog (null, "couldn't find a webbrowser to use...\nPlease browser for yourself:\n" + url);
		}
	}
}
