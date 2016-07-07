# Functions for reading Maclean's RSS feeds
library(XML)

#' Read and Parse RSS
#'
#' @param feed_url the url of a Maclean's RSS feed
#' @return a list containing a MacleansRSSChannel and a list of MacleansArticle objects
#'
#' @examples
#' \dontrun{
#'   main_rss = "http://www.macleans.ca/feed/"
#'   parsed_feed = readMacleansFeed(main_rss)
#'
#'   channel = parsed_feed[["channel"]]
#'   articles = parsed_feed[["articles"]]
#' }
#' 
#' @import XML
readMacleansFeed <- function(feed_url) {
    tree = xmlParse(feed_url, isURL=TRUE)
    doc_namespaces = xmlNamespaceDefinitions(tree, simplify=TRUE)

    validate_tree(tree)

    # Parse XML into objects
    rss = xmlRoot(tree)
    channel = .parseChannel(rss[["channel"]], doc_namespaces)

    item_xpath = "//channel/item"
    #items = getNodeSet(tree, item_xpath, doc_namespaces)
    articles = xpathSApply(tree, item_xpath, .parseItem, node_ns=doc_namespaces)

    return(list(channel=channel, articles=articles))
}


#' Parses a channel item from the channel XML node
#' 
#' This uses XPaths to extract values from 
#' the channel's child nodes.  All xpaths
#' should be relative to the channel_node.
#' 
#' @param channel_node a <channel> xml node
#' @param node_ns the node namespace definitions
#' @return a MacleansRSSChannel object
.parseChannel <- function(channel_node, node_ns) {
    title_xpath = "./title"
    url_xpath   = "./atom:link[@href]" #require href attr
    desc_xpath  = "./description"

    title   = .takeFirst(getNodeSet(channel_node, title_xpath))
    url     = .takeFirst(getNodeSet(channel_node, url_xpath, node_ns), function(x) xmlGetAttr(x, "href"))
    desc    = .takeFirst(getNodeSet(channel_node, desc_xpath)) #currently unused

    #derive our name from page url (should be unique)
    name_regex = ".+macleans.ca/(.+)/feed?/"

    if (grepl(name_regex, url)) {
        name = gsub(name_regex, "\\1", url)
        name = tolower(gsub("\\W", "", name)) #clean name characters
    } else {
        name = "main" #for main feed
    }

    return(MacleansRSSChannel(name=name, url=url))
}


#' Parses an article item from the item XML node
#' 
#' @param node an <item> xml node
#' @param node_ns the node namespace definitions, default null
#' @return a MacleansArticle object
.parseItem <- function(item_node, node_ns) {
    title_xpath             = "./title"
    desc_xpath              = "./description"
    content_xpath           = "./content:encoded"
    creator_xpath           = "./dc:creator"
    pub_date_xpath          = "./pubDate"
    category_xpath          = "./category"
    url_xpath               = "./link"
    guid_xpath              = "./guid" #take whole url here
    comment_url_xpath      = "./comments"
    comment_count_xpath    = "number(./slash:comments)" #get number directly

    return(MacleansArticle(
                title           = .takeFirst(getNodeSet(item_node, title_xpath)),
                description     = .takeFirst(getNodeSet(item_node, desc_xpath)),
                content         = .takeFirst(getNodeSet(item_node, content_xpath, node_ns)),
                creator         = .takeFirst(getNodeSet(item_node, creator_xpath, node_ns)),
                pubdate         = .takeFirst(getNodeSet(item_node, pub_date_xpath), getNodeDateTime),
                categories      = .takeAll(getNodeSet(item_node, category_xpath)),
                url             = .takeFirst(getNodeSet(item_node, url_xpath)),
                guid            = .takeFirst(getNodeSet(item_node, guid_xpath)),
                comment_url     = .takeFirst(getNodeSet(item_node, comment_url_xpath)),
                comment_count   = .takeFirst(getNodeSet(item_node, comment_count_xpath, node_ns), function(x) as.integer(x))
    ))
}


#' Get POSIX datetime from datetime node
#' 
#' Feeds appear to use the format "%a, %d %b %Y %H:%M:%S %z"
#' E.g. 'Wed, 06 Jul 2016 22:46:32 +0000'
#' 
#' @param node an XML node whose value is a datetime string
#' @param format the date-time format to use for conversion to POSIX object
#' @return a POSIX date object representation of the node
getNodeDateTime <- function(node, format="%a, %d %b %Y %H:%M:%S %z") {
    return(strptime(xmlValue(node), format))
}


#' Utility method for getting the first node's value
#' 
#' @param node_set a set of XML nodes as returned by getNodeSet
#' @param extract an extracting function, default is xmlValue
#' @return the xmlValue of the first node
.takeFirst <- function(node_set, extract=xmlValue) {
    return(extract(node_set[[1]]))
}


#' Just an alias for xmlSApply to make code clearer
#' 
#' @param node_set a set of XML nodes as returned by getNodeSet
#' @param extract an extracting function, default is xmlValue
#' @return the result of applying the extract function to all of the nodes
.takeAll <- function(node_set, extract=xmlValue) {
    return(xmlSApply(node_set, extract))
}


#' Assert XML tree of the expected format
#' 
#' Throws an error if tree does not have the expected format.
#' Throws warnings in case the tree does not appear well-formed
#' (e.g. if it has no Items)
#' 
#' @param tree the XML tree
validate_tree <- function(tree) {
    # Check tree structure
    root = xmlRoot(tree)
    if (xmlName(root) != "rss" || xmlSize(root) != 1) {
        stop("Root node should be named 'rss' and have only one branch")
    }

    trunk = root[[1]]
    if (xmlName(trunk) != 'channel') {
        stop("Expected main branch to be named 'channel'")
    }

    # Check channel contains item nodes
    branchNames = xmlSApply(trunk, xmlName)
    if (!any(branchNames == "item")) {
        warning("Channel contains no items", call.=FALSE, immediate.=TRUE)
    }

    #TODO: validate channel and item nodes here
}

