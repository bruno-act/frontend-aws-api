const { getDb } = require('/opt/db-connection');

const util = require('/opt/util'); // Layer utility file, contains generic functions

const auth = require('/opt/auth'); // Layer authorization file, contains generic functions

function verify(requestBody) {

    if (!requestBody.username || !requestBody.token) {
        return util.buildResponse(401, {
            verified: false,
            message: "incorrect request body, both username and token required"
        })
    }

    const username = requestBody.username;
    const token = requestBody.token;
    const verification = auth.verifyToken(username, token);

    if (!verification.verified) {
        return util.buildResponse(401, verification);
    }

    return util.buildResponse(200, {
        verified: true,
        message: "success",
        username: username,
        token: token
    })
}

module.exports.verify = verify;