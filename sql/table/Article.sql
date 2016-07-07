 /* Table for news articles */

 DROP TABLE IF EXISTS Article;

CREATE TABLE Article (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    title           VARCHAR(255),
    description     TEXT,
    content         TEXT,
    creator         VARCHAR(255),
    pubdate         DATETIME,
    url             VARCHAR(255),
    guid            VARCHAR(255),
    comment_url     VARCHAR(255),
    comment_count   INTEGER,
    UNIQUE(url)
);
