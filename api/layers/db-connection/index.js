const { getDb } = require('db-connection'); // Layer connection file, connects to db using credentials from secrets manager

const util = require('/opt/util'); // Layer utility file, contains generic functions

exports.handler = async (event) => {

    console.log('get providers event: ');

    console.log(event);

    const db = await getDb();

    console.log(db);

    const providers = await db('providers').select();

    console.log(providers);

    var response = !providers ? util.buildResponse(403, {
        message: "error fetching providers"
    })
        : util.buildResponse(200, {
            providers
        });

    return response;

    // try {



    //     return response;


    // } catch (error) {

    //     console.log(error);

    //     return util.buildResponse(502, {
    //                                     message: "failed to connect to db"
    //                                 });

    // }

}