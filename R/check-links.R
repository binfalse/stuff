library(MASS)

x=read.table("check-links.log")
intern=x[,1]
extern=x[,2]
z <- kde2d(intern,extern, n=50)

# cluster
colnames(x) <- c("internal", "external")
(cl <- kmeans(x, 2))

# draw
png("check-links.png", width = 600, height = 600)

# save actual settings
op <- par()
layout( matrix( c(2,1,0,3), 2, 2, byrow=T ), c(1,6), c(4,1))

par(mar=c(1,1,5,2))
contour(z, col = "black", lwd = 2, drawlabels = FALSE)
points(x, col =  2*cl$cluster, pch = 2 * (cl$cluster - 1),lwd=2,cex=1.3)
points(cl$centers, col = c(2,4), pch = 13, cex=3,lwd=3)
rug(side=1, intern )
rug(side=2, extern )
abline(lm( external ~ internal, data = x))
title(main = "internal -vs- external links per site")

# boxplot left
par(mar=c(1,2,5,1))
boxplot(extern, axes=F)
title(ylab='external links', line=0)

# boxplot right
par(mar=c(5,1,1,2))
boxplot(intern, horizontal=T, axes=F)
title(xlab='internal links', line=1)
# restore settings
par(op)

dev.off()
