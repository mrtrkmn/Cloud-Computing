module.exports = function (options) {
    //Import the mock data json file
    const mockData = require('./MOCK_DATA.json');

    //Add the patterns and their corresponding functions
    this.add('role:product,cmd:getProductURL', productURL);
    this.add('role:product,cmd:getProductName', productName);

    //Describe the logic inside the function
    function productURL(msg, respond) {

        var myFoundProduct = '';
        for(var i=0; i <mockData.length;i++ ) {

            if(mockData[i].product_id == msg.productId ){
                myFoundProduct = i + 1;
                break;
            }
        }
        if(myFoundProduct){
            respond(null, { result: mockData[myFoundProduct - 1].product_url});
        }
        else {
            respond(null, { result: ''});
        }

    }
    //Describe the logic inside the function
    function productName(msg, respond) {
        var myFoundProduct = '';
        for(var i=0; i <mockData.length;i++ ) {

            if(mockData[i].product_id == msg.productId ){
                myFoundProduct = i + 1;
                break;
            }
        }
        if(myFoundProduct){
            respond(null, { result: mockData[myFoundProduct - 1].product_name});
        }
        else {
            respond(null, { result: ''});
        }
    }
}