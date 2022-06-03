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
  res.json({
    message: 'Welcome to my app api!',
    documentationUrl: '', //leave this also blank for the first exercise
    baseUrl: '', //leave this blank for the first exercise
    endpoints: [
      {method: 'GET', path: '/api', description: 'Describes all available endpoints'},
      {method: 'GET', path: '/api/profile', description: 'Data about me'},
      {method: 'GET', path: '/api/books/', description: 'Get All books information'},
      {method: 'POST', path: '/api/books/', description: 'Insert a new book information'},
      {method: 'PUT', path: '/api/books/', description: 'Update a book information, based on id'},
      {method: 'DELETE', path: '/api/books/', description: 'Delete a book information, based on id'},
      // TODO: Write other API end-points description here like above
    ]
  })
});

app.get('/api/profile', (req, res) => {
  res.json({
    'name': 'John',
    'homeCountry': 'Winterfell',
    'degreeProgram': 'Night\'s Watch',//informatics or CSE.. etc
    'email': 'john@got.com',
    'deployedURLLink': '',//leave this blank for the first exercise
    'apiDocumentationURL': '', //leave this also blank for the first exercise
    'currentCity': 'The Wall',
    'hobbies': ['Fight White Walkers']

  });
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
   * use the books model and create a new object
   * with the information in req.body
   */
  db.books.create(req.body, (err, newBook) => {
    if (err) throw err;
    /*
     * return the new book information object as json
     */
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
   * use the books model and find using the bookId and update the book information
   */
  db.books.findOneAndUpdate({_id: bookId}, bookNewData, {new: true},
                            (err, updatedBookInfo) => {
    if (err) throw err;
    /*
     * Send the updated book information as a JSON object
     */
    res.json(updatedBookInfo);
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
   * use the books model and find using the bookId and delete the book
   */
  db.books.findOneAndRemove({_id: bookId}, (err, deletedBook) => {
    if (err) throw err;
    /*
     * Send the deleted book information as a JSON object
     */
    res.json(deletedBook);
  });
});
// TODO:  Add API end point /api/exercise2
/**********
 * SERVER *
 **********/
app.get('/api/exercise2', (req, res) => {
  res.send("group 84 application deployed using docker")
})

// listen on the port 3000
app.listen(process.env.PORT || 3000, () => {
  console.log('Express server is up and running on http://localhost:3000/');
});
