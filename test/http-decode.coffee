httpUtil = require '../lib/http'
httpUtil.get
    host:'tejia.taobao.com'
    path:'/tejia_list.htm'
    headers:
        'User-Agent':'Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.89 Safari/537.1'
        'Accept-Charset':'UTF-8,*;q=0.5'
    data:
        pid:1
    decode:true
,(err,data)->
    if err
        console.error err
    else
        console.log data