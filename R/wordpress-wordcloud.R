library(RMySQL)
require(wordcloud)
require(RColorBrewer)

# special chars we want to delete
sent=c(",", "\\.", ";", "=", ":", "\\?", "!", "-", "\\(", "\\)", "\\*", "&", "%", "$", "\\+", "\"", "'", "<", ">", "\\[", "\\]", "\\{", "\\}", "\\/", "\\\\")
# wordpress bb-codes, also delete!
bbcd=c("\\[cc.+?/cci?\\]", "\\[latex.+?/latex\\]", "\\[caption.+?/caption\\]")
# and of course delet HTML tags
tags=c("a", "b", "abbr", "strong", "em", "i", "p", "more", "td", "table", "tr", "th", "script", "h1", "h2", "h3", "h4", "h5", "h6", "div", "span", "small","img")
tags=paste("</?", tags, "[^>]*>", sep="")
# combine all purge-regex'
repl=c(tags, bbcd, sent)

# connect to your DB
con <- dbConnect(MySQL(), user="USER", password="PASSPHRASE", dbname="DB", host="HOST")
# select all published articles
res <- dbGetQuery(con, "SELECT post_content, post_title FROM wp_posts WHERE post_status='publish'")
#combine them in a text
text=paste(as.matrix(res), collapse=" ")
dbDisconnect(con)

# replace all unwanted stuff
tmp=sapply(repl, function (r) text<<-gsub(r, " ", text))
# here are our words:
words=table(strsplit(tolower(text), "\\s+"))

# remove words with _bad_ chars (non utf-8 stuff)
words=words[nchar(names(words), "c")==nchar(names(words), "b")]
# remove words shorter then 4 chars
words=words[nchar(names(words), "c")>3]
# remove words occuring less than 5 times
words=words[words>4]

# create the image
png("/tmp/cloud.png", width=580, height=580)
pal2 <- brewer.pal(8,"Set2")
wordcloud(names(words), words, scale=c(9,.1),min.freq=3, max.words=Inf, random.order=F, rot.per=.3, colors=pal2)
dev.off()
