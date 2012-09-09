package de.binfalse.martin;

import java.io.File;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;

import org.xml.sax.SAXException;



/**
 * The XMLValidator to validate XML files.
 * 
 * @author martin scharm
 */
public class XMLValidator
{
	
	/** The validator. */
	Validator	validator;
	
	
	/**
	 * Instantiates a new XML validator.
	 * 
	 * @param schemaFile
	 *          the schema file
	 * @throws SAXException
	 */
	public XMLValidator (File schemaFile) throws SAXException
	{
		validator = SchemaFactory.newInstance ("http://www.w3.org/2001/XMLSchema")
			.newSchema (schemaFile).newValidator ();
	}
	
	
	/**
	 * Validate a file.
	 * 
	 * @param xmlFile
	 *          the XML file to validate
	 * @return true, if file is valid
	 */
	public boolean validateFile (File xmlFile)
	{
		try
		{
			Source source = new StreamSource (xmlFile);
			long time = System.currentTimeMillis ();
			validator.validate (source);
			time = System.currentTimeMillis () - time;
			System.out.println ("took: " + time / 1000 + "s");
			return true;
		}
		catch (Exception e)
		{
			e.printStackTrace ();
		}
		return false;
	}
	
	
	/**
	 * The main method for testing purposes.
	 * 
	 * @param args
	 *          the arguments
	 */
	public static void main (String[] args)
	{
		args = new String[] { "/tmp/schema.xsd", "/tmp/testfile.xml" };
		try
		{
			System.out.println ("creating val");
			XMLValidator validator = new XMLValidator (new File (args[0]));
			System.out.println ("validating");
			if (validator.validateFile (new File (args[1])))
			{
				System.out.println ("file is valid!");
				return;
			}
			else
				System.out.println ("file is invalid!");
		}
		catch (SAXException e)
		{
			System.out.println ("sax error:");
			e.printStackTrace ();
		}
		System.exit (1);
	}
	
}

