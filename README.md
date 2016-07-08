# Maclean's Reader
Utilities for reading and storing Maclean's Magazine articles

## Background
[Maclean's Magazine](http://www.macleans.ca/) publishes news articles and multimedia on their website and provide RSS feeds through the Wordpress platform.  There are multiple channels such as _multimedia_, _sports_, _economy_ etc. which are found at addresses of the format `http://www.macleans.ca/<channel>/feed/` as well as a catch-all main channel found at `http://www.macleans.ca/feed/`.

## Code Structure

**/R** - R code for reading and writing feeds

- `examples.R` - example script which reads RSS feeds, writes to database and generates JSON
- `classes.R` - object definitions
- `feed.R` - functions for reading and parsing RSS feeds
- `sqlite.R` - functions for writing objects to a SQLite database
- `json.R` - functions for writing feeds to JSON

**/sql** - SQLite database definitions


## How to run examples script

Run from the command line with RScript, from the project directory using:

`RScript R/examples.R`

Alternatively, from within R, working in the project directory:

`source("R/examples.R", echo=FALSE)`

This will read some feeds from Macleans.ca, print some details, create a SQLite database and store the feeds to it and then write the multimedia feed to a JSON file.

## Requirements
This code uses the `XML` and `RSQLite` and `jsonlite` R packages. It was developed with R version 3.2.5.



