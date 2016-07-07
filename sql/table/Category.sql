/* Table for article categories / tags */

DROP TABLE IF EXISTS Category;

CREATE TABLE Category (
    id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name    VARCHAR(255)
);
