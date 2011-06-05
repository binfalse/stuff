// ==UserScript==
// @name           SquirrelMail search reorder
// @namespace      binfalse
// @description    resort everything ;)
// @include        https://YourSquirrelMailServer*/search.php*
// ==/UserScript==

var tds = document.getElementsByTagName ('td');
var table = 0;
// find the right table..
for (var i = 0; i < tds.length; i++)
{
	if(tds[i].innerHTML.match(/^\s*<b>From<\/b>\s*$/))
	{
		table = tds[i].parentNode.parentNode;
		break;
	}
}

// did we find a table!? failed searches don't provide one
if (table)
{
	var old = table.cloneNode (true);
	var tru = false;
	var oldi = old.childNodes.length - 1;
	var tablelen = table.childNodes.length;
	for (var i = 0; i < tablelen; i++)
	{
		// don't sort the head to the end...
		if (!tru)
		{
			if (table.childNodes[i].innerHTML && table.childNodes[i].innerHTML.replace(/\n/g,'').match (/<b>From<\/b>.*<b>Date<\/b>.*<b>Subject<\/b>/))
				tru = true;
			continue;
		}
		table.replaceChild (old.childNodes[oldi--], table.childNodes[i]);
	}
}
