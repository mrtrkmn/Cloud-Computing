const app = require('./app');
const config = require('./config');
/**
 * Start the server
 * our router is now pointing to /exercises
 */
app.listen(config.server.port, function () {
    console.log('Server listening on port 8080!')
});