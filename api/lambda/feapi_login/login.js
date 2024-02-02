const { getDb } = require('/opt/db-connection'); // Layer connection file, connects to db using credentials from secrets manager

const util = require('/opt/util'); // Layer utility file, contains generic functions

const auth = require('/opt/auth'); // Layer auth file, contains auth and token functions

const bcrypt = require('bcryptjs');

async function login(user) {

    const username = user.username;
    const password = user.password;

    const isUsernameEmpty = util.validateRequired(username, 'username');
    if (isUsernameEmpty != null)
        return isUsernameEmpty;

    const isPasswordEmpty = util.validateRequired(password, 'password');
    if (isPasswordEmpty != null)
        return isPasswordEmpty;

    const db = await getDb();

    const dbUser = await getUser(db, username.toLowerCase().trim());
    if (!dbUser) {
        return util.buildResponse(403, {
            message: "user record does not exist"
        });
    }

    if (!bcrypt.compareSync(password, dbUser.password)) {
        return util.buildResponse(403, {
            message: "password is incorrect"
        })
    }

    const userInfo = {
        username: dbUser.username,
        email: dbUser.email
    }

    const token = auth.generateToken(userInfo);

    const dbUpdatedUserToken = await updateUserToken(db, dbUser.slug, token);
    if (!dbUpdatedUserToken) {
        return util.buildResponse(403, {
            message: "failed to update user token in db record"
        });
    }

    const response = {
        user: userInfo,
        token: token
    }

    return util.buildResponse(200, response);

}

async function getUser(db, username) {

    return await db('admins').where({ username: username }).first().then((row) => row).catch((e) => {
        console.log('Get user failed with error');
        console.log(e);
        return null;
    });
}

async function updateUserToken(db, slug, token) {

    return await db("admins").update({ api_token: token })
        .where("slug", slug).then(rows => {
            // the argument here as you stated
            // describes the number of rows updated
            // therefore if no row found no row will be updated
            if (!rows) {
                console.log('Failed to update db user api token, no db rows effected');
                return false;
            }
            return true;
        }).catch((e) => {
            console.log('Failed to update db user api token');
            console.log(e);
            return false;
        });
}

module.exports.login = login;