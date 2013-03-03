httpUtil = require '../lib/http'
httpUtil.download 'https://a248.e.akamai.net/assets.github.com/images/modules/dashboard/bootcamp/octocat_fork.png?9a65c67e','../download/octocat_fork.png',(err)->
    if err
        console.error err
    else
        console.log 'download and save success.'