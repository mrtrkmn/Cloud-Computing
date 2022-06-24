module.exports = function (options) {
    //Import the mock data json file
    const mockData = require('./MOCK_DATA.json');

    //Add the patterns and their corresponding functions
    this.add('role:product,cmd:getProductURL', productURL);
    this.add('role:product,cmd:getProductName', productName);


    //To DO: add the pattern functions and describe the logic inside the function
    
    function productURL(msg, respond) {
        //Get the product id from the message
        const productId = msg.productId;
        
        if (!productId) {
            //If the product id is not found, return the product URL
            respond(null, {result: -1});
        } else {
            mockData.forEach(function (product) {
                if (product.id == productId) {
                    //If the product id is found, return the product url
                    respond(null, {productURL: product.url});
                }
        }
    );}
    }

    function productName(msg, respond) {
        //Get the product id from the message
        const productId = msg.productId;
        if (!productId) {
            //If the product id is not found, return the product name
            respond(null, {result: -1});
        } else {
            mockData.forEach(function (product) {
                if (product.id == productId) {
                    //If the product id is found, return the product name
                    respond(null, {result: product.name});
                }
            }
        );}
    }

}