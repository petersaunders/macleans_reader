 /* Table for news articles */

 DROP TABLE IF EXISTS Article;

CREATE TABLE Article (
    id
    title           VARCHAR(255),
    description     TEXT,
    content         TEXT,
    creator_id      INTEGER,
    pub_date        DATETIME,
    url             VARCHAR(255),
    guid            VARCHAR(255),
    comment_url     VARCHAR(255),
    comment_count   INTEGER,
    created         DATETIME,
    updated         DATETIME
);
