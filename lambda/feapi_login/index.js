const loginService = require('/opt/login'); // Layer login file, caters for user login 

exports.handler = async (event) => {

    console.log('login event: ');

    console.log(event);

    const body = JSON.parse(event.body);

    const response = await loginService.login(body);

    return response;
};