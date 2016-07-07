/* Join of articles with all their categories */

DROP VIEW IF EXISTS ArticleCategories;

CREATE VIEW ArticleCategories AS
        SELECT art.*, cat.name AS category_name FROM Article art
        JOIN ArticleCategory ac ON art.id = ac.article_id
        JOIN Category cat ON ac.category_id = cat.id;
