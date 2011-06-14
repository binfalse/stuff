function init()
{
	clock();
	setInterval(clock,1000);
}
function draw (ctx, x, y, stroke)
{
	ctx.beginPath(); 
	ctx.arc(x, y, 9, 0, Math.PI*2,true);
	if (stroke) ctx.stroke();
	else ctx.fill ();
}
function clock ()
{
	var canvas = document.getElementById("clock");  
	if (canvas.getContext)
	{  
		var offset = 60;
		var ctx = canvas.getContext("2d");
		ctx.save();
		ctx.clearRect(0,0,300,300); 
		var now = new Date();
		var sec = now.getSeconds();  
		var min = now.getMinutes(); 
		var hr  = now.getHours(); 
		for (var i = 0; i < 3; i++)
			for (var x = 0; x < 2; x++)
				for (var y = 0; y < 3; y++)
				{
					draw (ctx, i*offset + x*20 + 20, y*20 + 20, true);
				}
		for (var x = 1; x < 3; x++)
			for (var y = 2; y < 4; y++)
			{
				ctx.beginPath();
				ctx.arc(x * offset, y * 20, 4, 0, Math.PI*2,true);
				ctx.fill ();
			}
		for (var x = 0; x < 2; x++)
			for (var y = 0; y < 3; y++)
			{
				if (sec & Math.pow (2, (1 - x) * 3 + 2 - y)) draw (ctx, 2*offset + x*20 + 20, y*20 + 20, false);
				if (min & Math.pow (2, (1 - x) * 3 + 2 - y)) draw (ctx, 1*offset + x*20 + 20, y*20 + 20, false);
				if (hr & Math.pow (2, (1 - x) * 3 + 2 - y)) draw (ctx, x*20 + 20, y*20 + 20, false);
			}
		ctx.fillText(hr + ":" + min + ":" + sec, 70, 80);
		ctx.restore();
	}
}
