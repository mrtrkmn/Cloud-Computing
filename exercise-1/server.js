// require express and other modules
const express = require('express');
const app = express();
// Express Body Parser
app.use(express.urlencoded({extended: true}));
app.use(express.json());

// Set Static File Directory
app.use(express.static(__dirname + '/public'));


/************
 * DATABASE *
 ************/

const db = require('./models');

/**********
 * ROUTES *
 **********/

/*
 * HTML Endpoints
 */

app.get('/', function homepage(req, res) {
  res.sendFile(__dirname + '/views/index.html');
});


/*
 * JSON API Endpoints
 */

app.get('/api', (req, res) => {
  // TODO: Document all your api endpoints below as a simple hardcoded JSON object.
  res.json({
    message: 'Welcome to my app api!',
    documentationUrl: '', //leave this also blank for the first exercise
    baseUrl: '', //leave this blank for the first exercise
    endpoints: [
      {method: 'GET', path: '/api', description: 'Describes all available endpoints'},
      {method: 'GET', path: '/api/profile', description: 'Data about me'},
      {method: 'GET', path: '/api/books/', description: 'Get All books information'},
      {method: 'POST' , path: '/api/books/' , description: 'Create a new book'},
      {method: 'DELETE', path: '/api/books/:id', description: 'Delete a book'},
      {method: 'PUT', path: '/api/books/:id', description: 'Update a book'}
      // TODO: Write other API end-points description here like above
    ]
  })
});
// TODO:  Fill the values
app.get('/api/profile', (req, res) => {
  res.json({
    'name': 'Ahmet',
    'homeCountry': 'Turkey',
    'degreeProgram': 'Informatics',//informatics or CSE.. etc
    'email': 'hi@mrturkmen.com',
    'deployedURLLink': '',//leave this blank for the first exercise
    'apiDocumentationURL': '', //leave this also blank for the first exercise
    'currentCity': 'Munich',
    'hobbies': ['reading books', 'diy tools', 'cycling']

  })
});
/*
 * Get All books information
 */
app.get('/api/books/', (req, res) => {
  /*
   * use the books model and query to mongo database to get all objects
   */
  db.books.find({}, function (err, books) {
    if (err) throw err;
    /*
     * return the object as array of json values
     */
    res.json(books);
  });
});
/*
 * Add a book information into database
 */
app.post('/api/books/', (req, res) => {

  /*
   * New Book information in req.body
   */
  console.log(req.body);
  /*
   * TODO: use the books model and create a new object
   * with the information in req.body
   */
  const title = req.body.title;
  const author = req.body.author;
  const releaseDate = req.body.releaseDate;
  const genre = req.body.genre;
  const rating = req.body.rating;
  const language = req.body.language;
  var newBook = {title: title, author: author, releaseDate: releaseDate, genre: genre, rating: rating, language: language  }

  db.books.create(newBook, function (err, newBook) {
    if (err) throw err;
    
    res.json(newBook);
  });
 

});

/*
 * Update a book information based upon the specified ID
 */
app.put('/api/books/:id', (req, res) => {
  /*
   * Get the book ID and new information of book from the request parameters
   */
  const bookId = req.params.id;
  const bookNewData = req.body;
  console.log(`book ID = ${bookId} \n Book Data = ${bookNewData}`);

  /*
   * TODO: use the books model and find using the bookId and update the book information
   */
  db.books.findOneAndUpdate({_id: bookId}, bookNewData, {new: true}, function (err, book) {
    if (err) throw err;
    /*
   * Send the updated book information as a JSON object
   */
    res.json({title: book.title, author: book.author, releaseDate: book.releaseDate, genre: book.genre, rating: book.rating});
  });

});
/*
 * Delete a book based upon the specified ID
 */
app.delete('/api/books/:id', (req, res) => {
  /*
   * Get the book ID of book from the request parameters
   */
  const bookId = req.params.id;
 
  /*
   * TODO: use the books model and find using
   * the bookId and delete the book
   */ 
  
  db.books.findOneAndDelete({_id:bookId}).then(result => {
    /*
   * Send the deleted book information as a JSON object
   */
    console.log(result);
    res.json(result);
  });

  

});


/**********
 * SERVER *
 **********/

// listen on the port 3000
app.listen(process.env.PORT || 3000, () => {
  console.log('Express server is up and running on http://localhost:3000/');
});
