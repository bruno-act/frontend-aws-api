const SecretsManager = require('secretsManager.js');

const knex = require("knex");

const secretName = "dev/act/frontendapi/test/mysql";

const region = "eu-west-1";

exports.getDb = async function () {

    try {

        console.log('connection start');

        var apiValue = await SecretsManager.getSecret(secretName, region);

        console.log(apiValue);

        const secret = JSON.parse(apiValue.SecretString);

        console.log(secret);

        const host = secret['host'];
        const user = secret['username'];
        const password = secret['password'];
        const database = secret['database'];

        const connection = {
            ssl: { rejectUnauthorized: false },
            host,
            user,
            password,
            database
        };

        console.log('connecting...');

        const db = knex({
            client: 'mysql2',
            connection: connection,
            requestTimeout: 600000,
        });

        console.log('connected');

        return db;

        // const benefits = await db('benefits').select();

        // console.log(benefits);

    } catch (error) {

        console.log(error);

    }

}
