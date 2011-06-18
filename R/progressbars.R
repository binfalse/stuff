steps <- 50

# raw
print ("raw solution")
for (i in 1:steps)
{
	print (paste (i, "of", steps))
	Sys.sleep (.1)
}

# less lines consuming
print ("less line consuming with cat and \r")
for (i in 1:steps)
{
	cat ("\r", 100*i/steps, "% ", sep="")
	Sys.sleep (.1)
}
cat ("\n")

# nicer
print ("less line consuming with cat and \r, nicer")
for (i in 1:steps)
{
	cat ("\r", paste (paste (rep ("O", 100*i/steps), collapse=""), "o", paste (rep (" ", 100 - 100*i/steps), collapse="")," ", 100*i/steps, "% ",sep=""))
	Sys.sleep (.1)
}
cat ("\n")

# with txtProgressBar from txtProgressBar
print ("with txtProgressBar from txtProgressBar")
bar <- txtProgressBar (min=0, max=steps, style=3)
for (i in 1:steps)
{
	setTxtProgressBar (bar, i)
	Sys.sleep (.1)
}
close (bar)

# visual with tkProgressBar from tcltk
print ("with tkProgressBar from tcltk")
library ("tcltk")
bar <- tkProgressBar (title="my small progress bar", min=0, max=steps, width=300)
for (i in 1:steps)
{
	setTkProgressBar (bar, i, label=paste(round(i/steps*100, 0), "%"))
	Sys.sleep (.1)
}
close(bar)

