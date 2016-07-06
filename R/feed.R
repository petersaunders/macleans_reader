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
    channel = .parseChannel(rss[["channel"]])

    item_xpath = "//channel/item"
    #items = getNodeSet(tree, item_xpath, doc_namespaces)
    articles = xpathSApply(tree, item_xpath, .parseItem, namespaces=doc_namespaces)

    return(list(channel=channel, articles=articles))
}


#' Parses a channel item from the channel XML node
#' 
#' This uses XPaths to extract values from 
#' the channel's child nodes.  All xpaths
#' should be relative to the channel_node.
#' 
#' @param channel_node a <channel> xml node
#' @param namespaces the document namespaces as a named vector
#' @return a MacleansRSSChannel object
.parseChannel <- function(channel_node, namespaces) {
    title_xpath = "./title"
    url_xpath   = "./atom:link[@href]" #require href attr
    desc_xpath  = "./description"

    title   = .takeFirst(getNodeSet(channel_node, title_xpath, namespaces))
    url     = .takeFirst(getNodeSet(channel_node, url_xpath, namespaces), function(x) xmlGetAttr(x, "href"))
    desc    = .takeFirst(getNodeSet(channel_node, desc_xpath, namespaces)) #currently unused

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
#' @param namespaces the document namespaces as a named vector
#' @return a MacleansArticle object
.parseItem <- function(item_node, namespaces) {
    title_xpath = "./title"
    url_xpath   = "./link"
    guid_xpath  = "./guid" #take whole url here
    desc_xpath  = "./description"
    content_xpath = "./content:encoded"
    creator_xpath = "./dc:creator"
    pub_date_xpath = "./pubDate"
    category_xpath = "./category"
    comments_url_xpath = "./comments"
    comments_count_xpath = "./slash:comments"

    return(MacleansArticle(
                title           = .takeFirst(getNodeSet(item_node, title_xpath, namespaces)),
                description     = .takeFirst(getNodeSet(item_node, desc_xpath, namespaces)),
                content         = .takeFirst(getNodeSet(item_node, content_xpath, namespaces)),
                creator         = .takeFirst(getNodeSet(item_node, creator_xpath, namespaces)),
                pubdate         = .takeFirst(getNodeSet(item_node, pub_date_xpath, namespaces)),
                categories      = .takeAll(getNodeSet(item_node, category_xpath, namespaces)),
                url             = .takeFirst(getNodeSet(item_node, url_xpath, namespaces)),
                guid            = .takeFirst(getNodeSet(item_node, guid_xpath, namespaces)),
                comment_url     = .takeFirst(getNodeSet(item_node, comments_url_xpath, namespaces)),
                comment_count   = .takeFirst(getNodeSet(item_node, comments_count_xpath, namespaces))
    ))
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

