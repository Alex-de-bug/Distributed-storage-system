const { MongoClient, ObjectId } = require('mongodb');

const url = 'mongodb://localhost:27017';
const dbName = 'db';

async function generateData() {
    const client = await MongoClient.connect(url);
    const db = client.db(dbName);
    
    // Clear all collections
    await db.collection('users').deleteMany({});
    await db.collection('posts').deleteMany({});
    await db.collection('messages').deleteMany({});

    // Helper function to generate random binary data
    const generateBinaryData = () => Buffer.from('1234567890abcdef', 'hex');
    
    // Helper function to get random element from array
    const getRandom = (arr) => arr[Math.floor(Math.random() * arr.length)];
    
    // Generate users (10,000 users)
    console.log('Generating users...');
    const users = [];
    for (let i = 1; i <= 10000; i++) {
        const user = {
            _id: new ObjectId(),
            firstName: `FirstName${i}`,
            lastName: `LastName${i}`,
            email: `user${i}@example.com`,
            age: 18 + (i % 60),
            password: Math.random().toString(36),
            profilePicture: {
                type: 'photo',
                data: generateBinaryData(),
                size: 1024 * i,
                width: 640 + i,
                height: 480 + i,
                thumbnailData: generateBinaryData(),
                compressionLevel: getRandom(['low', 'medium', 'high'])
            },
            subscribers: []
        };
        users.push(user);
    }
    
    // Add subscribers (100,000 subscriptions)
    console.log('Adding subscribers...');
    users.forEach(user => {
        const subscriberCount = Math.floor(Math.random() * 20); // Average 10 subscribers per user
        for (let i = 0; i < subscriberCount; i++) {
            const randomUser = getRandom(users);
            if (randomUser._id !== user._id) {
                user.subscribers.push({
                    userId: randomUser._id,
                    status: Math.random() < 0.7 ? 'approved' : 'pending',
                    subscribeTime: new Date()
                });
            }
        }
    });
    
    // Insert users
    await db.collection('users').insertMany(users);
    
    // Generate content items (100,000 items)
    console.log('Generating posts...');
    const mediaTypes = ['photo', 'video', 'sticker', 'text'];
    const posts = [];
    
    for (let i = 1; i <= 10000; i++) {
        const contentCount = Math.floor(Math.random() * 5) + 1; // 1-5 content items per post
        const content = [];
        
        for (let j = 0; j < contentCount; j++) {
            const type = getRandom(mediaTypes);
            const baseContent = {
                type,
                data: generateBinaryData(),
                size: 1024 * (i + j),
                order: j
            };
            
            // Add type-specific properties
            switch (type) {
                case 'photo':
                    Object.assign(baseContent, {
                        width: 640 + i,
                        height: 480 + i,
                        thumbnailData: generateBinaryData(),
                        compressionLevel: getRandom(['low', 'medium', 'high'])
                    });
                    break;
                case 'video':
                    Object.assign(baseContent, {
                        duration: 60 + i,
                        frameRate: 24.0,
                        resolution: '1280x720',
                        bitrate: 2000000 + (i * 1000),
                        codec: 'H.264'
                    });
                    break;
                case 'sticker':
                    Object.assign(baseContent, {
                        stickerCode: `sticker${i}`,
                        category: i % 2 === 0 ? 'funny' : 'cute',
                        isPremium: i % 5 === 0,
                        cost: i % 20
                    });
                    break;
                case 'text':
                    Object.assign(baseContent, {
                        length: 100 + i,
                        textContent: `Sample text ${i}${i} Sample text`
                    });
                    break;
            }
            content.push(baseContent);
        }
        
        // Generate comments
        const commentCount = Math.floor(Math.random() * 10);
        const comments = [];
        for (let k = 0; k < commentCount; k++) {
            comments.push({
                userId: getRandom(users)._id,
                createdAt: new Date(),
                updatedAt: new Date(),
                likesCount: Math.floor(Math.random() * 100),
                content: [{
                    type: 'text',
                    data: generateBinaryData(),
                    order: 0
                }]
            });
        }
        
        posts.push({
            userId: getRandom(users)._id,
            createdAt: new Date(),
            updatedAt: new Date(),
            visibility: getRandom(['public', 'friends', 'private']),
            isPinned: i % 10 === 0,
            likesCount: i * 5,
            content,
            comments
        });
    }
    
    // Insert posts
    await db.collection('posts').insertMany(posts);
    
    // Generate messages (10,000 messages)
    console.log('Generating messages...');
    const messages = [];
    for (let i = 1; i <= 10000; i++) {
        const sender = getRandom(users);
        let receiver;
        do {
            receiver = getRandom(users);
        } while (receiver._id === sender._id);
        
        messages.push({
            senderId: sender._id,
            receiverId: receiver._id,
            createdAt: new Date(),
            isRead: Math.random() < 0.5,
            isDelivered: true,
            content: [{
                type: getRandom(mediaTypes),
                data: generateBinaryData(),
                order: 0
            }]
        });
    }
    
    // Insert messages
    await db.collection('messages').insertMany(messages);
    
    console.log('Data generation completed');
    await client.close();
}

generateData().catch(console.error);