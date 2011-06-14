// ==UserScript==
// @name           GalaxyDatasetImprover
// @namespace      binfalse
// @description    tabularize datasets
// @include        http://main.g2.bx.psu.edu/datasets/*/display/?preview=True
// ==/UserScript==

if (!document.doctype)
{

	var html = document.createElement('html');
	var body = document.createElement('body');
	var input = document.createElement('input');
	var pre = document.createElement('pre');
	var org = document.createTextNode(document.body.innerHTML.replace (/<[/]?pre>/g, ""));
	
	input.type = 'submit';
	input.value= 'create table';
	input.addEventListener('click',tabularize,true);
	
	pre.style.fontSize = '8px';
	pre.id = 'binfalseCheatData';
	
	pre.appendChild (org);
	body.appendChild(input)
	body.appendChild (pre);
	html.appendChild(body);
	
	
	while (document.hasChildNodes())
	{
		document.removeChild (document.firstChild);
	}
	
	document.appendChild(html);
}

function tabularize()
{
	var element = document.getElementById ('binfalseCheatData');
	if (element)
	{
		var tab = document.createElement('table');
		var lines = element.innerHTML.split("\n");
		for (var l = 0; l < lines.length; l++)
		{
			if ((l - 1) % 5 == 0)
			{
				var trBreak = document.createElement('tr');
				trBreak.style.border = '1px solid black';
				trBreak.style.height = '3px';
				tab.appendChild (trBreak);
			}
			var tr = document.createElement('tr');
			var tds = lines[l].split("\t");
			for (var t = 0; t < tds.length; t++)
			{
				var td = document.createElement('td');
				if (l == 0) td = document.createElement('th');
				var txt = document.createTextNode(tds[t]);
				td.appendChild (txt);
				td.style.paddingLeft = '5px';
				td.style.paddingRight = '5px';
				td.style.fontSize = '8px';
				tr.appendChild (td);
			}
			tab.appendChild (tr);
		}
		var parent = element.parentNode;
		parent.removeChild (element);
		parent.appendChild (tab);
		return true;
	}
	return false;
}
