// Generated by CoffeeScript 1.4.0
(function() {
  var httpUtil;

  httpUtil = require('../lib/http');

  httpUtil.get('http://www.baidu.com', function(err, data) {
    if (err) {
      return console.error(err);
    } else {
      return console.log(data);
    }
  });

}).call(this);
