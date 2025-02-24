BEGIN;

DROP TABLE IF EXISTS CommentContent;
DROP TABLE IF EXISTS Comment;
DROP TABLE IF EXISTS MessageContent;
DROP TABLE IF EXISTS Message;
DROP TABLE IF EXISTS PostContent;
DROP TABLE IF EXISTS Post;
DROP TABLE IF EXISTS Sticker;
DROP TABLE IF EXISTS Video;
DROP TABLE IF EXISTS User_Subscribe;
DROP TABLE IF EXISTS User_tw;
DROP TABLE IF EXISTS Photo;
DROP TABLE IF EXISTS Text;
DROP TABLE IF EXISTS Content;

-- Drop indexes from Post table
DROP INDEX IF EXISTS idx_post_created_at;
DROP INDEX IF EXISTS idx_post_likes;
DROP INDEX IF EXISTS idx_post_user_likes;
DROP INDEX IF EXISTS idx_post_created;

-- Drop indexes from PostContent table
DROP INDEX IF EXISTS idx_postcontent_content_post;

-- Drop indexes from Content table
DROP INDEX IF EXISTS idx_content_media;

-- Drop indexes from User_Subscribe table
DROP INDEX IF EXISTS idx_user_subscribe_composite;
DROP INDEX IF EXISTS idx_user_subscribe_mutual;

COMMIT;