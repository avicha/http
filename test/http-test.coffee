httpUtil = require '../lib/http'
httpUtil.get 'http://www.baidu.com',(err,data)->
    if err
        console.error err
    else
        console.log data
