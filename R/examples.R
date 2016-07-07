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
str(main_feed, max.level=1)
print(main_feed$channel)

# Print the top article in each feed
print(main_feed$articles[[1]])
print(multimedia_feed$articles[[1]])
print(sports_feed$articles[[1]])

#--- Database Writing / Reading ---

# Initialise a new database
initialiseDatabase("example_macleans.db", sqlfolder="sql", overwrite=TRUE)

# Show tables in database
conn = dbConnect(SQLite(), "example_macleans.db")
dbListTables(conn)

# Write all these feeds to the database
write_feed(main_feed, conn)
write_feed(multimedia_feed, conn)
write_feed(sports_feed, conn)

# Look at stored results (NB these obviously depend on what the feeds contained when run)
channels    = dbGetQuery(conn, "SELECT * FROM Channel;")
authors     = dbGetQuery(conn, "SELECT * FROM Creator;")
categories  = dbGetQuery(conn, "SELECT * FROM Category LIMIT 10;")

# Run some more complex queries

# Close db connection
dbDisconnect(conn)

#--- Generate JSON of feeds
