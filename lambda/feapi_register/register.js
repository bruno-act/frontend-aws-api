const { getDb } = require('/opt/db-connection'); // Layer connection file, connects to db using credentials from secrets manager
// const util = require('./utils/util');

const util = require('/opt/util'); // Layer utility file, contains generic functions

const bcrypt = require('bcryptjs');

async function register(userInfo) {

    console.log(userInfo);

    const slug = util.generateRandomString(12);
    const username = userInfo.username;
    const firstName = userInfo.firstName;
    const lastName = userInfo.lastName;
    const email = userInfo.email;
    const mobile = userInfo.mobile;
    const type = userInfo.type;
    const password = userInfo.password;

    console.log("username: " + username);

    const isUsernameEmpty = util.validateRequired(username, 'username');
    if (isUsernameEmpty != null)
        return isUsernameEmpty;

    const isFirstNameEmpty = util.validateRequired(firstName, 'firstName');
    if (isFirstNameEmpty != null)
        return isFirstNameEmpty;

    const isLastNameEmpty = util.validateRequired(lastName, 'lastName');
    if (isLastNameEmpty != null)
        return isLastNameEmpty;

    const isEmailEmpty = util.validateRequired(email, 'email');
    if (isEmailEmpty != null)
        return isEmailEmpty;

    const isMobileEmpty = util.validateRequired(mobile, 'mobile');
    if (isMobileEmpty != null)
        return isMobileEmpty;

    const isTypeEmpty = util.validateRequired(type, 'type');
    if (isTypeEmpty != null)
        return isTypeEmpty;

    const isPasswordEmpty = util.validateRequired(password, 'password');
    if (isPasswordEmpty != null)
        return isPasswordEmpty;

    const db = await getDb();

    console.log('DB instance');

    console.log(db);

    const dbUser = await getUser(db, username.toLowerCase().trim());
    if (dbUser && dbUser.username) {
        return util.buildResponse(401, {
            message: "username already exists in our database, please choose a different username"
        });
    }

    const encryptedPassword = bcrypt.hashSync(password.trim(), 10);

    const user = {
        slug: slug,
        username: username.toLowerCase().trim(),
        first_name: firstName,
        last_name: lastName,
        email: email,
        mobile: mobile,
        type: type,
        password: encryptedPassword

    }

    const savedUserResponse = await saveUser(db, user);
    if (!savedUserResponse) {
        return util.buildResponse(503, {
            message: "Server Error. Please try again later"
        })
    }

    return util.buildResponse(200, {
        username: username
    })
}

async function getUser(db, username) {

    return await db('admins').where({ username: username }).first().then((row) => row).catch((e) => {
        console.log('Get user failed with error');
        console.log(e);
        return null;
    });;
}

async function saveUser(db, user) {

    return await db('admins').insert(user).then((newUser) => {
        console.log('Saved user');
        console.log(newUser);
        return true;
    }).catch((e) => {
        console.log('Save user failed with error');
        console.log(e);
        return false;
    });

}

module.exports.register = register;