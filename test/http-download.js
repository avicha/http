// Generated by CoffeeScript 1.4.0
(function() {
  var httpUtil;

  httpUtil = require('../lib/http');

  httpUtil.download('https://a248.e.akamai.net/assets.github.com/images/modules/dashboard/bootcamp/octocat_fork.png?9a65c67e', '../download/octocat_fork.png', function(err) {
    if (err) {
      return console.error(err);
    } else {
      return console.log('download and save success.');
    }
  });

}).call(this);
