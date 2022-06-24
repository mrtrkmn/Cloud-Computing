module.exports = function (options) {
    //Import the mock data json file
    const mockData = require('./MOCK_DATA.json');
    //To DO: Add the patterns and their corresponding functions
    this.add('role:product,cmd:getProductPrice', productPrice);

    //To DO: add the pattern functions and describe the logic inside the function
    function productPrice(msg, respond) {
        //Get the product id from the message
        const productId = msg.productId;
        mockData.forEach(function (product) {
            if (product.id == productId) {
                //If the product id is found, return the product price
                respond(null, {result: product.price});
            }
            else {
                //If the product id is not found, return an error message
                respond(null, {result: "Product not found"});
            }
        }
        );}

    
}