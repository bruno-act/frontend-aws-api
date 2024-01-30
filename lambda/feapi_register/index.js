const registerService = require('./register'); // Layer registration file, caters for user registartion

const util = require('/opt/util'); // Layer utility file, contains generic functions

exports.handler = async (event) => {

    console.log('register backend event: ');

    console.log(event);

    const registerBody = JSON.parse(JSON.stringify(event));

    const response = await registerService.register(registerBody);

    return response;

};
