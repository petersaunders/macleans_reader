# Maclean's Reader
Utilities for reading and storing Maclean's Magazine articles

## Background
The [Maclean's Magazine](http://www.macleans.ca/) publishes news articles and multimedia on their website and provide RSS feeds through the Wordpress platform.  There are multiple channels such as _multimedia_, _sports_, _economy_ etc. which are found at addresses of the format `http://www.macleans.ca/<channel>/feed/` as well as a catch-all main channel found at `http://www.macleans.ca/feed/`.

## Database
This code is written to use an [SQLite](http://www.macleans.ca/?p=896743) database.  The SQL _may_ be compatible with other database vendors.  The database interface within the code is entirely SQLite specific.

## Requirements
This code uses the `XML` and `RSQLite` and `jsonlite` R packages. It was developed with R version 3.2.5 and SQLite 3.8.10.2. 

## Examples
Fully-functional examples can be found in the `R/examples.R` file.  Functions are documented using ROxygen in-line function documentation which also contains standalone function examples.



