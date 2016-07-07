# Functions for reading/writing Macleans RSS objects to an SQLite database
library(RSQLite)

#' Initialise a Macleans article database
#' 
#' This may be more convenient than running the SQL files externally
#' and guarantees (through RSQLite) that SQLite is available.  However
#' it is MUCH better to run sql files manually if possible.
#' 
#' @param dbfile the database file to use
#' @param sqlfolder the path to the folder containing the sql files, default is sql
#' @param overwrite should any existing database be overwritten, default FALSE
initialiseDatabase <- function(dbfile, sqlfolder="sql", overwrite=FALSE) {

    #Check if database exists
    if (file.exists(dbfile) & !overwrite) {
        stop("Database file already exists")
    }

    #Get SQL files
    getSqlFiles <- function(subdir) {
        list.files(file.path(sqlfolder, subdir), "*.sql", full.names=TRUE)
    }

    tables = getSqlFiles("table")
    views  = getSqlFiles("view")

    #Create new connection (and file if not exists)
    con = dbConnect(SQLite(), dbname=dbfile)

    #Run all sql files
    for (tb in c(tables, views)) {
        cat("\tRunning SQL:", tb, "\n")
        tb_sql = readSqlFile(tb)

        for (qry in tb_sql) {
            res = dbGetQuery(con, qry)
        }
    }

    invisible(dbDisconnect(con))
}


#' Read SQL file into character vector
#' 
#' @param sqlfile the sql file to read from
readSqlFile <- function(sqlfile) {
    #TODO This is VERY brittle and crude - not recommended for reuse!
    sqlLines = readLines(sqlfile)
    sqlQueries = unlist(strsplit(paste(sqlLines, collapse=" "),";"))
    return(sqlQueries)
}


#' Write a feed to the database
write_feed <- function(feed, con) {
    channel = feed[['channel']]

    cat("\tWriting channel '", channel@name, "'...\n", sep="")
    write_channel(channel, con)

    # Get channel id
    query = "SELECT id FROM Channel WHERE name=?;"
    channel_id = dbGetPreparedQuery(con, query, bind.data = data.frame(name=channel@name))[['id']]
    cat("\tChannel_id for '", channel@name, "': ", channel_id, "\n", sep="")

    # Write articles
    for (art in feed[['articles']]) {
        #cat("Writing article with url '", art@url, "'...\n", sep="")
        write_article(channel_id, art, con)
    }
}


#' Write a channel to the database
#' 
#' @param channel the MacleansRSSChannel object
#' @param con a database connection
write_channel <- function(channel, con) {
    stopifnot(class(channel) == "MacleansRSSChannel")

    #Write new channel or ignore error if already exists
    query = "INSERT OR IGNORE INTO Channel (name, url) VALUES (?, ?);"
    channel_df = data.frame(name = channel@name, url = channel@url)

    dbGetPreparedQuery(con, query, bind.data=channel_df)
}


#' Write an article to the database
#' 
#' @param channel_id the id of the channel through which the article was retrieved
#' @param article the MacleansArticle object to write
#' @param con a database connection
write_article <- function(channel_id, article, con) {
    stopifnot(class(article) == "MacleansArticle")

    # Write article item
    query = "INSERT OR IGNORE INTO Article (title, description, content, creator,
             pubdate, url, guid, comment_url, comment_count) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);"

    article_df = data.frame(title           = article@title,
                            description     = article@description,
                            content         = article@content,
                            creator         = article@creator,
                            pubdate         = article@pubdate,
                            url             = article@url,
                            guid            = article@guid,
                            comment_url     = article@comment_url,
                            comment_count   = article@comment_count)

    dbGetPreparedQuery(con, query, bind.data=article_df)

    # Get article id
    query = "SELECT * FROM Article WHERE url = ?;"
    article_id = dbGetPreparedQuery(con, query, bind.data=data.frame(url=article@url))[['id']]

    # Write article-channel association
    query = "INSERT OR IGNORE INTO ChannelArticle (channel_id, article_id) VALUES (?, ?);"
    dbGetPreparedQuery(con, query, bind.data=data.frame(channel_id, article_id))

    # Write categories
    for (category in article@categories) {
        query = "INSERT OR IGNORE INTO Category (name) VALUES (?);"
        cat_df = data.frame(name = category)
        dbGetPreparedQuery(con, query, bind.data=cat_df)

        # Write article-category association
        query = "SELECT * FROM Category WHERE name = ?;"
        category_id = dbGetPreparedQuery(con, query, bind.data=data.frame(name=category))[['id']]

        query = "INSERT OR IGNORE INTO ArticleCategory (article_id, category_id) VALUES (?, ?)"
        dbGetPreparedQuery(con, query, bind.data=data.frame(article_id, category_id))
    }
}
