httpUtil = require '../lib/http'
httpUtil.get 
    url:'http://www.baidu.com'
    proxy:true
,(err,data)->
    if err
        console.error err
    else
        console.log data