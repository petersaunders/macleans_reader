# Macleans feed examples
source("R/classes.R")
source("R/feed.R")
source("R/sqlite.R")
source("R/json.R")

#--- Feed Reading / Parsing

# Example feed channels
MAIN_FEED_URL       = "http://www.macleans.ca/feed"
MULTIMEDIA_FEED_URL = "http://www.macleans.ca/multimedia/feed"
SPORTS_FEED_URL     = "http://www.macleans.ca/sports/feed"

# Example reading feeds
main_feed       = readMacleansFeed(MAIN_FEED_URL)
multimedia_feed = readMacleansFeed(MULTIMEDIA_FEED_URL)
sports_feed     = readMacleansFeed(SPORTS_FEED_URL)

# Feeds are read into nested lists
cat("Feed Object Structure:\n")
str(main_feed, max.level=1)
print(main_feed$channel)

# Print the top 5 sports articles
cat("Multimedia Articles:\n")
print(multimedia_feed$articles[1:5])

#--- Database Writing / Reading ---

# Initialise a new database
initialiseDatabase("example_macleans.db", sqlfolder="sql", overwrite=TRUE)

# Show tables in database
conn = dbConnect(SQLite(), "example_macleans.db")

cat("Database Tables:\n")
dbListTables(conn)

# Write all these feeds to the database
write_feed(main_feed, conn)
write_feed(multimedia_feed, conn)
write_feed(sports_feed, conn)

# Look at stored results (NB results depend on what the feeds contained when retrieved)
channels    = dbGetQuery(conn, "SELECT * FROM Channel;")
categories  = dbGetQuery(conn, "SELECT * FROM Category LIMIT 20;")

cat("First Few Categories:\n")
print(categories)

# Look at views / more complex queries
jays_articles = dbGetQuery(conn, "SELECT title, url FROM ArticleCategories
                WHERE category_name LIKE '%jays%';")

brexit_articles = dbGetQuery(conn, "SELECT title, url FROM ArticleCategories
                                    WHERE category_name LIKE '%brexit%';")

top_authors = dbGetQuery(conn, "SELECT creator, COUNT(DISTINCT(id)) AS article_count 
                                  FROM Article GROUP BY creator
                                  ORDER BY article_count DESC LIMIT 10")

cat("Top Authors:\n")
print(top_authors)

top_categories = dbGetQuery(conn, "SELECT cat.id, cat.name, COUNT(DISTINCT(article_id)) AS article_count
                                   FROM Category cat 
                                   JOIN ArticleCategory ac ON cat.id = ac.category_id 
                                   GROUP BY cat.id 
                                   ORDER BY article_count DESC LIMIT 10;")

cat("Top Categories:\n")
print(top_categories)

# Close db connection
invisible(dbDisconnect(conn))

#--- Generate JSON of feed
multimedia_json = feedToJSON(multimedia_feed)

#Write feed json to file
cat(multimedia_json, file="multimedia_feed.json")
cat("JSON file written to multimedia_feed.json\n")
