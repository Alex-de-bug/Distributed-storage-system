const { MongoClient, ObjectId } = require('mongodb');

const url = 'mongodb://localhost:27017';
const dbName = 'db';

async function runQueries() {
    const client = await MongoClient.connect(url);
    const db = client.db(dbName);

    try {
        // Drop existing indexes first
        await db.collection('posts').dropIndexes();
        await db.collection('users').dropIndexes();

        console.log('\nCreating optimized indexes...');

        // Query 1 optimized indexes
        await db.collection('posts').createIndex({ 
            "createdAt": -1 
        }, { name: "query1_date" });
        
        await db.collection('posts').createIndex({ 
            "content.data": 1,
            "likesCount": -1
        }, { name: "query1_content_likes" });

        // Query 2 optimized indexes
        await db.collection('posts').createIndex({ 
            "userId": 1,
            "content.type": 1,
            "likesCount": -1
        }, { name: "query2_user_content" });

        await db.collection('users').createIndex({ 
            "subscribers.userId": 1,
            "subscribers.status": 1,
            "_id": 1
        }, { name: "query2_subs" });

        // Query 3 optimized indexes
        await db.collection('users').createIndex({ 
            "subscribers.status": 1,
            "_id": 1,
            "subscribers.userId": 1
        }, { name: "query3_mutual_opt" });

        await db.collection('users').createIndex({ 
            "_id": 1,
            "subscribers.status": 1
        }, { name: "query3_lookup_opt" });

        // Verify indexes
        console.log('\nPosts collection indexes:');
        const postsIndexes = await db.collection('posts').listIndexes().toArray();
        console.log(JSON.stringify(postsIndexes, null, 2));

        console.log('\nUsers collection indexes:');
        const usersIndexes = await db.collection('users').listIndexes().toArray();
        console.log(JSON.stringify(usersIndexes, null, 2));

    } catch (error) {
        console.error('Error creating indexes:', error);
    }

    try {
        // Query 1
        console.log('\nExecuting Query 1: Top 10 popular content items');
        const startTime1 = process.hrtime();
        const topContent = await db.collection('posts').aggregate([
            { $match: { createdAt: { $gte: new Date(new Date().setMonth(new Date().getMonth() - 1)) } } },
            { $unwind: "$content" },
            {
                $group: {
                    _id: "$content.data",
                    mediaType: { $first: "$content.type" },
                    totalLikes: { $sum: "$likesCount" },
                    creators: { $addToSet: { userId: "$userId" } }
                }
            },
            {
                $lookup: {
                    from: "users",
                    localField: "creators.userId",
                    foreignField: "_id",
                    as: "creators"
                }
            },
            {
                $project: {
                    _id: 1,
                    mediaType: 1,
                    totalLikes: 1,
                    creatorNames: {
                        $map: {
                            input: "$creators",
                            as: "creator",
                            in: { $concat: ["$$creator.firstName", " ", "$$creator.lastName"] }
                        }
                    },
                    creatorEmails: { $map: { input: "$creators", as: "creator", in: "$$creator.email" } }
                }
            },
            { $sort: { totalLikes: -1 } },
            { $limit: 10 }
        ]).toArray();
        const endTime1 = process.hrtime(startTime1);
        console.log('Top 10 content items:', JSON.stringify(topContent, null, 2));
        console.log(`Query 1 execution time: ${endTime1[0]}s ${endTime1[1] / 1000000}ms`);

        // Query 2
        console.log('\nExecuting Query 2: Content recommendations');
        const startTime2 = process.hrtime();
        const userId = new ObjectId("67bcd82d600e47715c3cf2a0"); // Заменить на реальный ID db.getCollection('users').find();
        const recommendations = await db.collection('posts').aggregate([
            {
                $facet: {
                    "likedTypes": [
                        { $match: { userId: userId, likesCount: { $gt: 0 } } },
                        { $unwind: "$content" },
                        { $group: { _id: "$content.type" } }
                    ],
                    "subscribedContent": [
                        {
                            $lookup: {
                                from: "users",
                                pipeline: [
                                    { $match: { "subscribers.userId": userId, "subscribers.status": "approved" } },
                                    { $project: { _id: 1 } }
                                ],
                                as: "subscribers"
                            }
                        },
                        { $match: { "subscribers": { $ne: [] } } },
                        { $unwind: "$content" }
                    ]
                }
            },
            {
                $project: {
                    content: {
                        $setUnion: [
                            "$subscribedContent.content",
                            {
                                $filter: {
                                    input: "$subscribedContent.content",
                                    as: "cont",
                                    cond: { $in: ["$$cont.type", "$likedTypes._id"] }
                                }
                            }
                        ]
                    }
                }
            },
            { $sort: { "createdAt": -1 } },
            { $limit: 5 }
        ]).toArray();
        const endTime2 = process.hrtime(startTime2);
        console.log('Content recommendations:', JSON.stringify(recommendations, null, 2));
        console.log(`Query 2 execution time: ${endTime2[0]}s ${endTime2[1] / 1000000}ms`);

        // Query 3
        console.log('\nExecuting Query 3: Mutual subscriptions');
        const startTime3 = process.hrtime();
        const mutualSubscriptions = await db.collection('users').aggregate([
            { $unwind: "$subscribers" },
            { $match: { "subscribers.status": "approved" } },
            {
                $lookup: {
                    from: "users",
                    let: { userId: "$_id", subscriberId: "$subscribers.userId" },
                    pipeline: [
                        {
                            $match: {
                                $expr: {
                                    $and: [
                                        { $eq: ["$_id", "$$subscriberId"] },
                                        {
                                            $in: ["$$userId", {
                                                $map: {
                                                    input: {
                                                        $filter: {
                                                            input: "$subscribers",
                                                            cond: { $eq: ["$$this.status", "approved"] }
                                                        }
                                                    },
                                                    as: "sub",
                                                    in: "$$sub.userId"
                                                }
                                            }]
                                        }
                                    ]
                                }
                            }
                        }
                    ],
                    as: "mutualSubscribers"
                }
            },
            { $match: { "mutualSubscribers": { $ne: [] } } },
            {
                $project: {
                    user1: "$_id",
                    user2: "$subscribers.userId"
                }
            },
            {
                $match: {
                    $expr: { $lt: ["$user1", "$user2"] }
                }
            }
        ]).toArray();
        const endTime3 = process.hrtime(startTime3);
        console.log('Mutual subscriptions:', JSON.stringify(mutualSubscriptions, null, 2));
        console.log(`Query 3 execution time: ${endTime3[0]}s ${endTime3[1] / 1000000}ms`);

        // Add total execution time
        console.log('\nTotal execution statistics:');
        console.log('----------------------------------------');
        console.log(`Query 1 (Top 10 popular): ${endTime1[0]}s ${endTime1[1] / 1000000}ms`);
        console.log(`Query 2 (Recommendations): ${endTime2[0]}s ${endTime2[1] / 1000000}ms`);
        console.log(`Query 3 (Mutual subs): ${endTime3[0]}s ${endTime3[1] / 1000000}ms`);
        console.log('----------------------------------------');

    } catch (error) {
        console.error('Error executing queries:', error);
    } finally {
        await client.close();
    }
}

runQueries().catch(console.error);