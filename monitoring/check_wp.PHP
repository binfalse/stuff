#!/usr/bin/php
<?php
###################################
#
#     WordPress Updates Monitoring
#     written by Martin Scharm
#       see http://binfalse.de
#
###################################

define ("OOK", 0);
define ("WRN", 1);
define ("ERR", 2);
define ("MMH", 3);

$instdir = null;
$domain = null;
$website = null;

$check_core = true;
$check_plugins = true;
$check_themes = true;
$verify_cert = true;

$help = false;
$version = "1.0";
$err = array ();

for ($i = 1; $i < count ($argv); $i++)
{
	switch ($argv[$i])
	{
	case "--domain":
		$domain = $argv[++$i];
		break;
	case "--dir":
		$instdir = $argv[++$i];
		break;
	case "--web":
		$website = $argv[++$i];
		break;
	case "--no-core":
		$check_core = false;
		break;
	case "--no-plugins":
		$check_plugins = false;
		break;
	case "--no-theme":
		$check_themes = false;
		break;
	case "--insec-cert":
		$verify_cert = false;
		break;
	default:
		$err[] = $argv[$i]."?";
		$help = true;
	}
}



if (!$website && !$instdir)
	$err[] = "no installation directory and no website, don't know what to check...";

if (!$check_core && !$check_plugins && !$check_themes)
	$err[] = "--no-core and --no-plugins and --no-theme? you must be kidding...";

if ($instdir && !file_exists ($instdir.'/wp-load.php'))
	$err[] = "your installation is way to old or your installation path isn't correct...";

if ($help || count ($err))
{
	if (count ($err))
		echo implode (" | ", $err)."\n";
	echo "Okay, let me help you... btw. this is version $version\n";
	echo "Valid arguments:\n";
	echo "\t--domain DOMAIN\tcheck for DOMAIN (required for multidomain installations)\n";
	echo "\t--dir DIRECTORY\twordpress installation directory can be found in DIRECTORY\n";
	echo "\t--web WEBSITE\tcheck _only_ the website WEBSITE (will just check the core version for updates, based on meta name generator)\n";
	echo "\t--insec-cert\tdon't verify SSL cert (in combination with --web)\n";
	echo "\t--no-core\tdon't check the core\n";
	echo "\t--no-plugins\tdon't check the plugins\n";
	echo "\t--no-theme\tdon't check the themes\n";
	echo "\t-h | --help\thelp me please\n\n";
	echo "that's it for the moment...\n";
	exit (MMH);
}



if ($website)
{
	// just check the website...
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $website);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_NOSIGNAL, 1);
if (!$verify_cert)
{
curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
}
	$data = curl_exec($ch);
	curl_close($ch);

	preg_match('/meta[^>]*generator[^>]*wordpress\s+([0-9.]+)/i', $data, $matches);
	if (count ($matches) < 2 || !$matches[1])
	{
		echo "no version in web found...\n";
		exit (WRN);
	}

	$ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, "http://api.wordpress.org/core/version-check/1.2/?version=" . $matches[1]);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_NOSIGNAL, 1);
        $data = curl_exec($ch);
        curl_close($ch);
	
	$data = explode ("\n", $data);
	if (version_compare  ($data[3], $matches[1]) > 0)
	{
		echo "Your core is out of date! " . $matches[1] . " -> " . $data[3] . "\n";
		exit (ERR);
	}

	// that's it
	echo "Running " . $matches[1] . " is fine.\n";
	exit (OOK);
}


// ok lets check a local installation!

if ($domain) // multihost
	$_SERVER['HTTP_HOST'] = $domain;

// include wp stuff, don't need to to reinvent the wheel...
require_once($instdir.'/wp-load.php');
	
// let wordpress prepare it's tests
wp_version_check();
wp_update_plugins();
wp_update_themes();

// if it's pre 2.9 get_site_transient might be missing... pretty old my friend!
if (!function_exists ("get_site_transient"))
{
	echo "OMG. Time to get some updates!!!";
	exit (ERR);
}

$ret = OOK;
$suppl = "";
$msg = array ();

// check the core of your wordpress
if ($check_core)
{
	$core = get_site_transient('update_core');
	if (isset ($core->updates) && version_compare  ($core->updates[0]->current, $core->version_checked) > 0)
	{
		$msg[] = "Core is out-of-date!";
		$suppl .= "Core: " . $core->version_checked . " -> " . $core->updates[0]->current . "; ";
		$ret = max ($ret, ERR);
	}
	else
		$msg[] = "Core is up-to-date.";
}
else
	$msg[] = "Skipping core checks!";

// check the plugins
if ($check_plugins)
{
	$plugin_msg = array ();
	$plugins = get_site_transient('update_plugins');
	if (isset ($plugins->response))
	{
		foreach($plugins->response as $name => $update)
		{
			$plugin_msg[] = $update->slug . ": " . $plugins->checked[$name] ." -> " . $update->new_version;
		}
	}
	if (count ($plugin_msg))
	{
		$s = "s are";
		if (count ($plugin_msg) == 1)
			$s = " is";
		$msg[] = count ($plugin_msg) . " plugin" . $s . " out-of-date!";
		$suppl .= implode ("; ", $plugin_msg) . "; ";
		$ret = max ($ret, ERR);
	}
	else
		$msg[] = "Plugins are up-to-date.";
}
else   
        $msg[] = "Skipping plugin checks!";

// check the themes
if ($check_themes)
{
	$themes_msg = array ();
	$themes = get_site_transient('update_themes');
	if (isset ($themes->response))
	{
		foreach($themes->response as $name => $update)
		{
			$themes_msg[] = $name . ": " . $themes->checked[$name] ." -> " . $update["new_version"];
		}
	}
	if (count ($themes_msg))
	{
		$s = "s are";
		if (count ($plugin_msg) == 1)
			$s = " is";
		$msg[] = count ($themes_msg) . " theme" . $s . " out-of-date!";
		$suppl .= implode ("; ", $themes_msg) . "; ";
		$ret = max ($ret, ERR);
	}
	else
		$msg[] = "Themes are up-to-date.";
}
else
	$msg[] = "Skipping theme checks!";


// collect our info
if ($ret == OOK)
	echo "Well done! ";
else
	echo "Need attention! ";

echo implode (" - ", $msg) . "|" . $suppl . "\n";
exit ($ret);

?>
