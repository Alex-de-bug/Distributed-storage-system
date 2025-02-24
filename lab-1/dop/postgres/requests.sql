Задача: Найти 10 самых популярных элементов контента (фото, видео, текст, стикеры) за последний месяц, 
основываясь на общем количестве лайков постов, в которых они использовались. 
Также, для каждого элемента контента, вернуть имена и email создателей этих постов.

Сложность: Требует объединения множества таблиц (Content, PostContent, Post, User_tw) и агрегации данных. 
Сложно масштабировать при увеличении объема данных.

EXPLAIN ANALYZE
SELECT
    c.id AS content_id,
    c.media_type,
    c.file_name,
    SUM(p.likes_count) AS total_likes,
    STRING_AGG(DISTINCT u.firstName || ' ' || u.lastName, ', ') AS creator_names,
    STRING_AGG(DISTINCT u.email, ', ') AS creator_emails
FROM
    Content c
JOIN
    PostContent pc ON c.id = pc.content_id
JOIN
    Post p ON pc.post_id = p.id
JOIN
    User_tw u ON p.user_id = u.id
WHERE
    p.created_at >= NOW() - INTERVAL '1 month'
GROUP BY
    c.id, c.media_type, c.file_name
ORDER BY
    total_likes DESC
LIMIT 10;

Задача: Для заданного пользователя (например, с user_id = 123), найти 5 наиболее подходящих элементов контента,
которые он еще не видел, основываясь на следующих критериях:
У контента есть лайки.
Контент от пользователей, на которых он подписан.
В данном случае, будем считать, что "похожий" контент - это контент того же media_type.

Сложность: Требует объединения таблиц подписок, постов, контента и пользователей, 
а также логики для фильтрации просмотренного контента.

EXPLAIN ANALYZE
WITH user_likes AS (
    SELECT DISTINCT c.media_type
    FROM Post p
    JOIN PostContent pc ON p.id = pc.post_id
    JOIN Content c ON pc.content_id = c.id
    WHERE p.user_id = 123 AND p.likes_count > 0 -- Предполагаем, что лайки = интерес
),
subscribed_users_content AS (
    SELECT c.id AS content_id, c.media_type, p.created_at
    FROM User_Subscribe us
    JOIN Post p ON us.subscribe_id = p.user_id
    JOIN PostContent pc ON p.id = pc.post_id
    JOIN Content c ON pc.content_id = c.id
    WHERE us.user_id = 123 AND us.status = 'approved'
),
similar_content AS (
    SELECT c.id AS content_id, c.media_type, p.created_at
    FROM Post p
    JOIN PostContent pc ON p.id = pc.post_id
    JOIN Content c ON pc.content_id = c.id
    JOIN user_likes ul ON c.media_type = ul.media_type
    WHERE p.user_id <> 123 -- Исключаем контент самого пользователя
)
SELECT content_id, media_type
FROM (
    SELECT content_id, media_type, created_at FROM subscribed_users_content
    UNION ALL
    SELECT content_id, media_type, created_at FROM similar_content
) AS combined_content
WHERE content_id NOT IN (SELECT content_id FROM PostContent WHERE post_id IN (SELECT id FROM Post WHERE user_id = 123)) -- Исключаем уже просмотренный контент
ORDER BY created_at DESC
LIMIT 5;

Задача: Найти всех пользователей, которые подписаны друг на друга (A подписан на B, и B подписан на A).

Сложность: Требует self-join и проверки условия взаимности.

EXPLAIN ANALYZE
SELECT
    us1.user_id AS user1_id,
    us2.user_id AS user2_id
FROM
    User_Subscribe us1
JOIN
    User_Subscribe us2 ON us1.user_id = us2.subscribe_id AND us1.subscribe_id = us2.user_id
WHERE
    us1.user_id < us2.user_id  -- Чтобы избежать дубликатов (A, B) и (B, A)
    AND us1.status = 'approved'
    AND us2.status = 'approved';
