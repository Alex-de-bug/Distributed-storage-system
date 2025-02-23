CREATE TABLE IF NOT EXISTS Content
(
    id SERIAL PRIMARY KEY,
    uploaded_at TIMESTAMP NOT NULL,
    file_data BYTEA NOT NULL,
    size BIGINT NOT NULL,
    file_name VARCHAR(255),
    mime_type VARCHAR(50) NOT NULL,
    media_type VARCHAR(7) NOT NULL CHECK (media_type IN ('photo', 'video', 'sticker', 'text')),
    hash VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS Text (
    id SERIAL PRIMARY KEY,
    content_id BIGINT UNIQUE NOT NULL,
    length INT CHECK (length > 0),
    content TEXT,

    FOREIGN KEY (content_id) REFERENCES Content(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Photo (
    id SERIAL PRIMARY KEY,
    content_id BIGINT UNIQUE NOT NULL,
    width INT CHECK (width > 0),
    height INT CHECK (height > 0),
    thumbnail_data BYTEA,
    compression_level VARCHAR(6) CHECK (compression_level IN ('low', 'medium', 'high')), 

    FOREIGN KEY (content_id) REFERENCES Content(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS User_tw
(
    id SERIAL PRIMARY KEY,
    firstName VARCHAR(100),
    lastName VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    profile_picture_id BIGINT NOT NULL,
    age INTEGER,
    password VARCHAR(100),
    
    FOREIGN KEY (profile_picture_id) REFERENCES Photo(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS User_Subscribe
(
    id SERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    subscribe_id BIGINT NOT NULL,
    subscribe_time TIMESTAMP,
    status VARCHAR(20) NOT NULL CHECK (status IN ('approved', 'reject', 'pending')),

    FOREIGN KEY (user_id) REFERENCES User_tw(id) ON DELETE CASCADE,
    FOREIGN KEY (subscribe_id) REFERENCES User_tw(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Video
(
    id SERIAL PRIMARY KEY,
    content_id BIGINT UNIQUE NOT NULL,
    duration INT CHECK (duration >= 0),
    frame_rate DECIMAL(5,2) CHECK (frame_rate > 0),
    resolution VARCHAR(20),
    bitrate BIGINT CHECK (bitrate >= 0),
    codec VARCHAR(50),

    FOREIGN KEY (content_id) REFERENCES Content(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Sticker
(
    id SERIAL PRIMARY KEY,
    content_id BIGINT UNIQUE NOT NULL,
    cost INT CHECK (cost >= 0),
    sticker_code VARCHAR(50) UNIQUE,
    category VARCHAR(50),
    is_premium BOOLEAN DEFAULT FALSE,

    FOREIGN KEY (content_id) REFERENCES Content(id) ON DELETE CASCADE
);

CREATE TABLE Post (
    id SERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP, 
    visibility VARCHAR(10) NOT NULL DEFAULT 'public' CHECK (visibility IN ('public', 'friends', 'private')), 
    is_pinned BOOLEAN DEFAULT FALSE,
    likes_count INT DEFAULT 0 CHECK (likes_count >= 0), 

    FOREIGN KEY (user_id) REFERENCES User_tw(id) ON DELETE CASCADE
);

CREATE TABLE PostContent (
    id SERIAL PRIMARY KEY,
    post_id BIGINT NOT NULL,
    content_id BIGINT NOT NULL,
    content_order INT DEFAULT 0,

    FOREIGN KEY (post_id) REFERENCES Post(id) ON DELETE CASCADE,
    FOREIGN KEY (content_id) REFERENCES Content(id) ON DELETE CASCADE
);

CREATE TABLE Message (
    id SERIAL PRIMARY KEY,
    sender_id BIGINT NOT NULL,
    receiver_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE, 
    is_delivered BOOLEAN DEFAULT FALSE, 
    parent_message_id BIGINT,

    FOREIGN KEY (sender_id) REFERENCES User_tw(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES User_tw(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_message_id) REFERENCES Message(id) ON DELETE SET NULL
);

CREATE TABLE MessageContent (
    id SERIAL PRIMARY KEY,
    message_id BIGINT NOT NULL,
    content_id BIGINT NOT NULL,
    content_order INT DEFAULT 0,

    FOREIGN KEY (message_id) REFERENCES Message(id) ON DELETE CASCADE,
    FOREIGN KEY (content_id) REFERENCES Content(id) ON DELETE CASCADE
);

CREATE TABLE Comment (
    id SERIAL PRIMARY KEY,
    post_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    parent_comment_id BIGINT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP,
    likes_count INT DEFAULT 0 CHECK (likes_count >= 0),

    FOREIGN KEY (post_id) REFERENCES Post(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES User_tw(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_comment_id) REFERENCES Comment(id) ON DELETE SET NULL
);

CREATE TABLE CommentContent (
    id SERIAL PRIMARY KEY,
    comment_id BIGINT NOT NULL,
    content_id BIGINT NOT NULL,
    content_order INT DEFAULT 0,

    FOREIGN KEY (comment_id) REFERENCES Comment(id) ON DELETE CASCADE,
    FOREIGN KEY (content_id) REFERENCES Content(id) ON DELETE CASCADE
);
