httpUtil = require '../lib/http'
httpUtil.get
    url:'http://www.weibo.com/avicha'
    maxDepth:1
    log:true
,(err,location)->
    if err
        console.error err
    else
        console.log location