const mongoose = require("mongoose");
mongoose.connect( process.env.MONGODB_URI ||
    "mongodb://localhost:27017/booksData",{ useNewUrlParser: true });

console.log(process.env.MONGODB_URI);
module.exports.books = require("./books.js");
