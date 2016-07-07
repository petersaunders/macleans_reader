# Macleans Feed JSON functions
library(jsonlite)

#' Convert a feed to JSON
#' 
#' @param feed a list containing a channel and an article list
#' @return a json object representing the feed
feedToJSON <- function(feed) {
    #jsonlite almost works out-of-the-box - just have to remove
    #the objects class attributes
    feed_unclassed = unclassFeed(feed)
    return(jsonlite::toJSON(feed_unclassed, force=TRUE, 
                    auto_unbox=TRUE, pretty=TRUE))
}


#' Remove class attributes from feed object
#' 
#' This just removes the class attributes from a feed
#' to make it suitable for conversion to JSON
#' 
#' @param feed a list containing a channel and an article list
#' @return 
unclassFeed <- function(feed) {
    channel  = unclass(feed[['channel']])
    articles = lapply(feed[['articles']], unclass)

    return(list(channel=channel, articles=articles))
}
