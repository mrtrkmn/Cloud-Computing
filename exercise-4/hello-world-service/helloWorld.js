module.exports = function (options) {
    //Add the patterns and their corresponding functions
    this.add('role:helloWorld,cmd:Welcome', sayWelcome);

    //Describe the logic inside the function
    function sayWelcome(msg, respond) {
        if(msg.name){
            var res = "Welcome "+msg.name;
            respond(null, { result: res });
        }
        else {
            respond(null, { result: ''});
        }
    }
}