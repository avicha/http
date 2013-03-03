httpUtil = require '../lib/http'
httpUtil.post 
    host:'https://login.taobao.com'
    path:'/member/login.jhtml'
    data:
        TPL_username:'username'
        TPL_password:'password'
    log:true
    decode:true
,(err,data,res)->
    if err
        console.error err
    else
        console.log res.statusCode
        console.log res.headers