/* Table for Macleans channels */

DROP TABLE IF EXISTS Channel;

CREATE TABLE Channel (
    id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name    VARCHAR(255),
    url     VARCHAR(255)
);
