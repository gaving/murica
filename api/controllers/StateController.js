var fs = require('fs');

module.exports = {
  _config: {},

  index: function (req, res, next) {
    fs.readFile('states.json', function(err, data){
      res.send(JSON.parse(data));
    });
  }
};
