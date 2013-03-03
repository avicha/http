http
=======

模块主要封装了http和https的get，post请求，增加了转码，跳转，代理服务器，下载
##安装
<pre>
    npm install yi-http
</pre>
##方法
* http.get(url,callback)
  url  :  请求的url，必须写完整的url，如http://www.baidu.com，包含协议，域名，端口，路径等。
  callback  :  回调函数，包含err：错误信息，data：请求返回内容

* http.get(options,callback)
  options:请求配置，详细参数如下：
    url  :  请求路径，要求如上面的url参数，输入了url参数则不必填充host,path,port,data参数了
    host  :  域名，默认为localhost
    path  :  请求路径，默认为/
    port  :  端口，默认为80
    data  :  请求查询参数
    decode  :  是否进行内容解码，默认false
    retry  :  请求失败重试次数，默认为3次
    timeout  :  设置请求超时，默认使用代理为5000ms，不使用代理为3000ms
    maxDepth  :  跳转最大深度，默认为0，即没有限制
    log  :  是否输出log帮助跟踪请求情况，默认为false
    headers  :  请求头部，默认为{}
    parseData  :  是否把请求参数的值转换为json序列化字符串，默认为false
    proxy  :  是否使用代理服务器，默认为false，代理服务器地址默认通过proxylist文件引入，当然你也可以直接指定代理服务器的地址，如'localhost:8087'
  callback  :  回调函数，包含err：错误信息，data：请求返回内容
* http.post(options,callback)
    options  :  配置跟get的基本一样，唯一不同的是data指定了发送的内容体，如果你想post JSON数据，请把parseData设置为true，例如：
```javascript
    http.post({
        host:'xxx.com',
        path:'/goods/get',
        data:{
          q:{id:'123456',price:50}
        },
        parseData:true
    },function(err,data){
        if(err){
          console.error(err);
        }
        else{
          console.log(data);
        }
    });
```
  callback  :  回调函数，包含err：错误信息，data：请求返回内容
* http.download(source,target,callback)
  source  :  下载文件的源地址
  target  :  保存文件的路径和文件名
  callback  :  下载完毕回调函数，包含err：错误信息

