fs = require 'yi-fs'
path = require 'path'
qs = require 'querystring'
url = require 'url'
iconv = require 'iconv-lite'
Task = require('yi-task').Task
_ = require 'underscore'
httpUtil = {}
httpUtil._limitNumber = 20
httpUtil._proxyList = require './proxylist'
httpUtil._proxyIndex = 0
_transform = (keys,val)->
    arr = []
    _.each val,(v,k,obj)->
        if _.isObject v
            arr = arr.concat _transform (keys.concat k),v
        else
            arr.push {keys:(keys.concat k),val:v}
    arr
_stringifyJSON = (json)->
    jsonarr = []
    _.each json,(val,key,obj)->
        if !_.isObject val
            jsonarr.push "#{key}=#{encodeURIComponent val}"
        else
            jsonarr = jsonarr.concat (_transform [],val).map (kvs)->"#{key}"+(kvs.keys.map (k)->"[#{k}]").join('')+"=#{encodeURIComponent kvs.val}"
    jsonarr.join('&')
_parseJSON = (json)->
    jsonarr = []
    _.each json,(val,key,obj)->
        if !_.isObject val
            jsonarr.push "#{key}=#{encodeURIComponent val}"
        else
            jsonarr.push "#{key}=#{encodeURIComponent JSON.stringify(val)}"
    jsonarr.join('&')
requestQueue = new Task 'http request',httpUtil._limitNumber,(options,config,callback,complete)->
    isError = false
    _request = (options,config,callback)->
        req = (require config.protocol).request options, (res)->
            buffer = new Buffer ''
            res.on 'data', (chunk)->
                clearTimeout reqtimeout
                newbuffer = new Buffer (buffer.length + chunk.length)
                buffer.copy newbuffer, 0
                chunk.copy newbuffer, buffer.length
                buffer = newbuffer
            res.on 'end', ()->
                clearTimeout reqtimeout
                res.dt = Date.now() - t
                content = buffer.toString()
                if config.log
                    console.log  "Response statusCode:#{res.statusCode}"
                    console.log  "Response headers:"
                    console.log res.headers
                    console.log  "Response content:"
                    console.log content.substring 0,1000
                    console.log  "Request #{options.host}:#{options.port}#{options.path} need time #{res.dt}"
                if res.statusCode == 200
                    if config.buffer
                        complete 1,0
                        callback null,buffer,res if !isError
                    else
                        if config.decode
                            encode = (res.headers && res.headers['content-type'] && (/charset=(.*)/.test res.headers['content-type']) && res.headers['content-type'].match(/charset=(.*)/)[1]) || ((/charset="(.*?)"/.test content) && content.match(/charset="(.*?)"/)[1]) || 'GBK'
                            content = iconv.decode buffer, encode
                        if config.format == 'json'
                            try
                                json = JSON.parse content.replace /\t/g,''
                            catch e
                                complete 0,1
                                callback "JSON对象转换失败：#{e}，内容是#{content}",content,res  if !isError
                                return
                            complete 1,0
                            callback null,json,res if !isError
                            
                        else
                            if config.format == 'jsonp'&&config.data&&config.data.callback
                                try
                                    regex = new RegExp config.data.callback + "\\(\(.*\)\\)"
                                    if regex.test content
                                        jsonp = JSON.parse content.match(regex)[1].replace /\t/g,'' 
                                    else
                                        throw new Error "不能匹配jsonp"
                                catch e
                                    complete 0,1
                                    callback "JSONP对象转换失败：#{e}，内容是#{content}",content,res if !isError
                                    return
                                complete 1,0
                                callback null,jsonp,res if !isError
                            else
                                complete 1,0
                                callback null,content,res if !isError
                else
                    if /^3\d\d$/.test res.statusCode
                        config.maxDepth--
                        if !config.maxDepth
                            complete 1,0
                            callback null,res.headers.location,res  if !isError
                        else
                            if config.log
                                console.log "Rediect to:#{res.headers.location}"
                            jumpUrl = res.headers.location || res.headers.Location
                            config.url = jumpUrl
                            config.headers['Referer'] = "#{config.protocol}://www.#{options.host}:#{options.port}#{options.path}"
                            complete 1,0
                            httpUtil._request config,callback
                    else
                        callback res.statusCode,content,res if !isError
        reqtimeout = setTimeout ()->
            req.emit 'error',message:"Request #{options.host}:#{options.port}#{options.path} Timeout!"
        ,config.timeout
        req.on 'error',(e)->
            if !isError
                isError = true
                req.abort()
                if config.retry
                    console.warn "Retry:#{config.retry},Error:#{e.message}"
                    config.retry--
                    complete 0,1
                    requestQueue.push options,config,callback
                else
                    complete 0,1
                    callback "Request error: #{options.host}#{options.path}出现以下错误：#{e.message}"
        if options.method == 'POST' and config.data
            if config.parseData
                req.write JSON.stringify config.data
            else
                req.write _stringifyJSON config.data
        t = Date.now()
        req.end()
    if config.proxy
        if _.isString config.proxy
            proxyinfo = config.proxy.split ':'
            proxyhost = proxyinfo[0]
            proxyport = proxyinfo[1]||80
            options.path = "http://www.#{options.host}:#{options.port}#{options.path}"
            options.host = proxyhost
            options.port = proxyport
            options.headers.Host = url.parse(options.path).hostname
            options.auth = ':'
            _request options,config,callback
        else
            httpUtil.getProxy (err,availProxy)->
                if err
                    complete 0,1
                    callback err
                else
                    options.path = "http://www.#{options.host}:#{options.port}#{options.path}"
                    options.host = availProxy.ip
                    options.port = availProxy.port
                    options.headers.Host = url.parse(options.path).hostname
                    options.auth = ':'
                _request options,config,callback
    else
        _request options,config,callback
httpUtil.getProxy = (callback)->
    if httpUtil._proxyList&&httpUtil._proxyList.length
        httpUtil._currentProxy = httpUtil._proxyList[httpUtil._proxyIndex]
        callback null,httpUtil._currentProxy
        httpUtil._proxyIndex = (httpUtil._proxyIndex+1)%httpUtil._proxyList.length
        httpUtil._currentProxy = httpUtil._proxyList[httpUtil._proxyIndex]
    else
        callback "The Proxy List is Empty!",null   
httpUtil._request = (config,callback)->
    config.retry ?= 3
    config.timeout ?= do ()->
        if config.proxy
            10000
        else
            5000
    config.maxDepth ?= 0
    config.log ?= false
    config.decode ?= false
    if config.url
        reqObj = url.parse config.url
        protocol = do ()->
            if reqObj.protocol == 'https:'
                'https'
            else
                'http'
        _.extend config,
            protocol:protocol
            host : "#{reqObj.protocol}//#{reqObj.hostname}"
            port : do ()->
                if reqObj.port
                    reqObj.port
                else
                    if protocol == 'https'
                        443
                    else
                        80
            path : "#{reqObj.pathname}"
            data : qs.parse reqObj.query
    else
        config.protocol = do ()->
            if config.host&&~config.host.indexOf 'https'
                'https'
            else
                'http'
    options =
        host : (config.host||'localhost').replace('http://','').replace('https://','')
        port : do ()->
            if config.port
                config.port
            else
                if config.protocol == 'https'
                    443
                else
                    80
        headers : config.headers ?= {}
        method : (config.method ?= 'get').toUpperCase()
    options.path = do ()->
        if config.path && options.method == 'GET'
            if config.data
                if config.parseData
                    querystring = '?'+ _parseJSON config.data
                else
                    querystring = '?'+_stringifyJSON config.data
            else
                querystring = ''
            config.path + querystring
        else 
            config.path ?= '/'
    #post请求设置请求头
    if options.method == 'POST' && config.data
        if config.parseData
            options.headers['Content-Type'] = 'application/json; charset=UTF-8'
            options.headers['Content-length'] = (new Buffer JSON.stringify config.data).length
        else
            options.headers['Content-Type'] ?= 'application/x-www-form-urlencoded; charset=UTF-8'
            options.headers['Content-length'] = (new Buffer _stringifyJSON config.data).length
    if config.log
        console.log '正在发送请求：'
        console.log  options
    requestQueue.push options,config,callback          
'get post'.split(' ').forEach (method)->
    httpUtil[method] = (config, callback) ->
        if _.isString config
            config = url:config
        config.method = method
        httpUtil._request config, callback  
httpUtil.download = (source,target,isCover,callback)->
    if !callback
        if _.isFunction isCover
            callback = isCover
            isCover = true
        else
            isCover ?= true
    if !isCover && fs.existsSync target
        callback null if callback
    else
        dir = path.dirname target
        fs.mkdirp dir,(err)->
            if err
                if callback
                    callback err
                else
                    throw new Error err
            else
                httpUtil.get {url:source,buffer:true},(err,buffer)->
                    if err
                        if callback
                            callback err
                        else
                            throw new Error err
                    else
                        if callback
                            fs.writeFile target,buffer,callback
                        else
                            fs.writeFileSync target,buffer
module.exports = httpUtil
            
