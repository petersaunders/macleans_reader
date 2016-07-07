/* Association table for article categories */

DROP TABLE IF EXISTS ArticleCategory;

CREATE TABLE ArticleCategory (
    article_id  INTEGER,
    category_id INTEGER,
    UNIQUE(article_id, category_id)
);
