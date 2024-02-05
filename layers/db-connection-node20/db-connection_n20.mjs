import { getSecret } from '/opt/secretsManager_n20.mjs';

import knex from 'knex';

// const secretName = "dev/act/frontendapi/test/mysql";

// const region = "eu-west-1";

async function getDb(secretName, region) {

    try {

        console.log('connection start');

        var secret = await getSecret(secretName, region);

        var jsonSecret = JSON.parse(secret);

        console.log(jsonSecret);

        const host = jsonSecret['host'];
        const user = jsonSecret['username'];
        const password = jsonSecret['password'];
        const database = jsonSecret['database'];

        const connection = {
            ssl: { rejectUnauthorized: false },
            host,
            user,
            password,
            database
        };

        console.log('db node 20 connecting...');

        console.log(connection);

        const db = knex({
            client: 'mysql2',
            connection: connection,
            requestTimeout: 600000,
            pool: {
                min: 0
            }
        });

        console.log('connected');

        console.log(db);

        return db;

    } catch (error) {

        console.log(error);

    }

}

export { getDb }
