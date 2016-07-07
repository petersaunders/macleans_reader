/* Table for Macleans channels */

DROP TABLE IF EXISTS Channel;

CREATE TABLE Channel (
    id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name    VARCHAR(255) UNIQUE,
    url     VARCHAR(255),
    UNIQUE(name) ON CONFLICT IGNORE
);
