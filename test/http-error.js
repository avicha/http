// Generated by CoffeeScript 1.4.0
(function() {
  var httpUtil;

  httpUtil = require('../lib/http');

  httpUtil.get({
    host: 'avicha.com',
    path: '/index',
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.89 Safari/537.1',
      'Accept-Charset': 'UTF-8,*;q=0.5'
    },
    data: {
      unknown: true
    },
    log: true
  }, function(err, data) {
    if (err) {
      return console.error(err);
    } else {
      return console.log(data);
    }
  });

}).call(this);
