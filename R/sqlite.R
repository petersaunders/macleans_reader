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

#' Insert or Update Row
#' 
#' This does an insert ignore and then updates the row if
#' it already exists.
#' 
#' @param con a database connection
#' @param table the table name to write to
#' @param key the unique-key fields
#' @param data a data-frame of parameters to store
#' @return the last insert id, if any
insertOrUpdate <- function(con, table, key, data) {

    #Generate insert-or-ignore query
    insertQuery = paste("INSERT OR IGNORE INTO ", table, " (",
                    paste(names(data), collapse=", "), ") VALUES (",
                    paste("@", names(data), sep="", collapse=", "), ");", sep="")


    #Generate update query
    updateQuery = paste("UPDATE ", table, " SET ",
                    paste(names(data), names(data), sep="=@", collapse=", "), 
                    " WHERE CHANGES()=0 AND ", 
                    paste(key, key, sep="=@", collapse=" AND "), ";",
                    sep="")

    #Get last addressed id
    #TODO: this hard-codes the id column name as 'id'
    lastIdQuery = paste("SELECT CASE CHANGES() WHEN 0 
                        THEN LAST_INSERT_ROWID()
                        ELSE (SELECT id FROM ", table, 
                        " WHERE ", paste(key, key, sep="=@", collapse=" AND "),
                        ") END AS id;", sep="")

    #Execute queries
    dbGetPreparedQuery(con, insertQuery, bind.data=data)
    dbGetPreparedQuery(con, updateQuery, bind.data=data)

    #Get last addressed row id
    id_df = dbGetPreparedQuery(con, lastIdQuery, bind.data=data)
    return(as.integer(id_df[['id']]))
}

#' Write a feed to the database
write_feed <- function(feed, con) {
    channel = feed[['channel']]

    cat("\tWriting channel '", channel@name, "'...\n", sep="")
    channel_id = write_channel(channel, con)

    # Write articles
    for (art in feed[['articles']]) {
        write_article(channel_id, art, con)
    }
}


#' Write a channel to the database
#' 
#' @param channel the MacleansRSSChannel object
#' @param con a database connection
#' @return the channel_id, invisibly
write_channel <- function(channel, con) {
    stopifnot(class(channel) == "MacleansRSSChannel")
    channel_df = data.frame(name=channel@name, url=channel@url)

    channel_id = insertOrUpdate(con, "Channel", "name", channel_df)
    invisible(channel_id)
}


#' Write an article to the database
#' 
#' @param channel_id the id of the channel through which the article was retrieved
#' @param article the MacleansArticle object to write
#' @param con a database connection
#' @return the article_id, invisibly
write_article <- function(channel_id, article, con) {
    stopifnot(class(article) == "MacleansArticle")

    article_data = data.frame(  title           = article@title,
                                description     = article@description,
                                content         = article@content,
                                creator         = article@creator,
                                pubdate         = article@pubdate,
                                url             = article@url,
                                guid            = article@guid,
                                comment_url     = article@comment_url,
                                comment_count   = article@comment_count)

    article_id = insertOrUpdate(con, "Article", "url", article_data)

    # Update the association table
    query = "INSERT OR IGNORE INTO ChannelArticle (channel_id, article_id) VALUES (?, ?);"
    dbGetPreparedQuery(con, query, bind.data=data.frame(channel_id, article_id))

    # Write categories
    for (category in article@categories) {
        category_df = data.frame(name = category)
        category_id = insertOrUpdate(con, "Category", "name", category_df)

        #Update the association table
        query = "INSERT OR IGNORE INTO ArticleCategory (article_id, category_id) VALUES (?, ?)"
        dbGetPreparedQuery(con, query, bind.data=data.frame(article_id, category_id))
    }

    invisible(article_id)
}
