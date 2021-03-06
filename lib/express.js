// Generated by CoffeeScript 1.12.7
(function() {
  var CoffeeScript;

  CoffeeScript = require('coffee-script/register');

  module.exports = {
    renderFile: function(path, options, callback) {
      return setImmediate(function() {
        var err;
        try {
          if ((options.app != null) && !options.app.enabled('view cache')) {
            delete require.cache[require.resolve(path)];
          }
          return callback(null, require(path)(options));
        } catch (error) {
          err = error;
          return callback(err);
        }
      });
    }
  };

}).call(this);
