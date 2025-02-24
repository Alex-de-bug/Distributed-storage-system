TRUNCATE TABLE CommentContent RESTART IDENTITY CASCADE;
TRUNCATE TABLE MessageContent RESTART IDENTITY CASCADE;
TRUNCATE TABLE PostContent RESTART IDENTITY CASCADE;
TRUNCATE TABLE User_Subscribe RESTART IDENTITY CASCADE;
TRUNCATE TABLE Comment RESTART IDENTITY CASCADE;
TRUNCATE TABLE Message RESTART IDENTITY CASCADE;
TRUNCATE TABLE Post RESTART IDENTITY CASCADE;
TRUNCATE TABLE Sticker RESTART IDENTITY CASCADE;
TRUNCATE TABLE Video RESTART IDENTITY CASCADE;
TRUNCATE TABLE Photo RESTART IDENTITY CASCADE;
TRUNCATE TABLE Text RESTART IDENTITY CASCADE;
TRUNCATE TABLE User_tw RESTART IDENTITY CASCADE;
TRUNCATE TABLE Content RESTART IDENTITY CASCADE;


-- Seed data for Content
DO $$
DECLARE
    i INT := 1;
BEGIN
    WHILE i <= 100000 LOOP
        INSERT INTO Content (uploaded_at, file_data, size, file_name, mime_type, media_type, hash)
        VALUES (NOW(), bytea('\x1234567890abcdef'), 1024 * i, 'file' || i || '.dat', 'application/octet-stream', CASE WHEN i % 4 = 0 THEN 'photo' WHEN i % 4 = 1 THEN 'video' WHEN i % 4 = 2 THEN 'sticker' ELSE 'text' END, md5(random()::text));
        i := i + 1;
    END LOOP;
END $$;

-- Seed data for Text
INSERT INTO Text (content_id, length, content)
SELECT id, 100 + id, 'Sample text ' || id || id || 'Sample text ' FROM Content WHERE media_type = 'text'  LIMIT 25000;

-- Seed data for Photo
INSERT INTO Photo (content_id, width, height, thumbnail_data, compression_level)
SELECT id, 640 + id, 480 + id, bytea('\x0123456789abcdef'), CASE WHEN id % 3 = 0 THEN 'low' WHEN id % 3 = 1 THEN 'medium' ELSE 'high' END
FROM Content WHERE media_type = 'photo' LIMIT 25000;

-- Seed data for User_tw
DO $$
DECLARE
    i INT := 1;
    profile_pic_id BIGINT;
BEGIN
    FOR i IN 1..10000 LOOP
        -- Select a random profile picture ID from the Photo table.
        SELECT id INTO profile_pic_id FROM Photo ORDER BY RANDOM() LIMIT 1;

        INSERT INTO User_tw (firstName, lastName, email, profile_picture_id, age, password)
        VALUES ('FirstName' || i, 'LastName' || i, 'user' || i || '@example.com', profile_pic_id, 18 + (i % 60), md5(random()::text));
    END LOOP;
END $$;

-- Seed data for User_Subscribe (allowing users to subscribe to each other with more randomness)
INSERT INTO User_Subscribe (user_id, subscribe_id, subscribe_time, status)
SELECT u1.id, u2.id, NOW(),
       CASE
           WHEN random() < 0.7 THEN 'approved'
           ELSE 'pending'  
       END
FROM User_tw u1
JOIN User_tw u2 ON u1.id <> u2.id 
WHERE random() < 0.05  
LIMIT 100000;

-- Seed data for Video
INSERT INTO Video (content_id, duration, frame_rate, resolution, bitrate, codec)
SELECT id, 60 + id, 24.00, '1280x720', 2000000 + (id * 1000), 'H.264'
FROM Content WHERE media_type = 'video' LIMIT 25000;

-- Seed data for Sticker
INSERT INTO Sticker (content_id, cost, sticker_code, category, is_premium)
SELECT id, id % 20, 'sticker' || id, CASE WHEN id % 2 = 0 THEN 'funny' ELSE 'cute' END, (id % 5 = 0)
FROM Content WHERE media_type = 'sticker' LIMIT 25000;

-- Seed data for Post
INSERT INTO Post (user_id, visibility, is_pinned, likes_count)
SELECT id, CASE WHEN id % 3 = 0 THEN 'public' WHEN id % 3 = 1 THEN 'friends' ELSE 'private' END, (id % 10 = 0), id * 5
FROM User_tw LIMIT 10000;

-- Seed data for PostContent - each post has at least one piece of content
INSERT INTO PostContent (post_id, content_id, content_order)
SELECT p.id, c.id, 0
FROM Post p
JOIN Content c ON c.id % 10000 = p.id % 10000  -- Simple way to link posts to SOME content
LIMIT 100000;

-- Seed data for Message
INSERT INTO Message (sender_id, receiver_id)
SELECT u1.id, u2.id
FROM User_tw u1, User_tw u2
WHERE u1.id < 51 AND u2.id > 50
LIMIT 10000;

-- Seed data for MessageContent
INSERT INTO MessageContent (message_id, content_id)
SELECT m.id, c.id
FROM Message m
JOIN Content c ON c.id % 10000 = m.id % 10000
LIMIT 100000;

-- Seed data for Comment
INSERT INTO Comment (post_id, user_id, likes_count)
SELECT p.id, u.id, u.id * 2
FROM Post p, User_tw u
WHERE p.id % 10000 = u.id % 10000
LIMIT 10000;

-- Seed data for CommentContent
INSERT INTO CommentContent (comment_id, content_id)
SELECT c.id, con.id
FROM Comment c
JOIN Content con ON con.id % 10000 = c.id % 10000
LIMIT 100000;

COMMIT;