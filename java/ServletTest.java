package de.binfalse.martin;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



/**
 * @author martin scharm
 * 
 */
public class ServletTest
	extends HttpServlet
{
	
	protected void doGet (HttpServletRequest request, HttpServletResponse response)
		throws ServletException,
			IOException
	{
		response.setContentType ("text/html");
		request.setCharacterEncoding ("UTF-8");
		PrintWriter out = response.getWriter ();
		
		out.println ("new File (\".\").getAbsolutePath () => " + new File (".").getAbsolutePath ());
		out.println ("request.getPathInfo () => " + request.getPathInfo ());
		out.println ("request.getPathTranslated () => " + request.getPathTranslated ());
		out.println ("request.getContextPath () => " + request.getContextPath ());
		out.println ("request.getRealPath (request.getServletPath ()) => " + request.getRealPath (request.getServletPath ()));
		out.println ("request.getServletPath () => " + request.getServletPath ());
		out.println ("getServletContext ().getContextPath () => " + getServletContext ().getContextPath ());
		out.println ("getServletContext ().getRealPath (\".\") => " + getServletContext ().getRealPath ("."));
	}
}
