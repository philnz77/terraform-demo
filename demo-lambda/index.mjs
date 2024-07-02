import Redis from 'ioredis';

// Configuration for Redis connection
const configurationEndpoint = process.env.CACHE_CONFIG_ENDPOINT;
const cachePort = parseInt(process.env.CACHE_PORT);
let redisClient;

export const handler = async (event) => {
     if (!redisClient) {
        redisClient = new Redis.Cluster(
            [
                {
                    port: cachePort, 
                    host: configurationEndpoint
                }
            ],
            {
                dnsLookup: (address, callback) => callback(null, address),
                redisOptions: {
                  tls: {},
                },
            }
        );

        // Handle connection errors
        redisClient.on('error', (err) => {
            console.error('Redis error', err);
        });
    }

    // // Example usage: SET key value in Redis
    // await redisClient.set('example-key', 'example-value');
    
    // // Example usage: GET key from Redis
    // const result = await redisClient.get('example-key');
    
    const counter = await redisClient.get('my-counter');
    const counterNum = parseInt(counter);
    const counterNumCleaned = isNaN(counterNum) ? 0 : counterNum;
    const nextNum = counterNumCleaned + 1;
    await redisClient.set('my-counter', String(nextNum));
    
    return {
        statusCode: 200,
        body: JSON.stringify({
            counterNumCleaned
        }),
    };

};

