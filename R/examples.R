# Macleans feed examples
source("classes.R")
source("feed.R")
source("sqlite.R")
source("json.R")

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

# Initialise a new database
