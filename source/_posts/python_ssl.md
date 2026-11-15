---
title: Python中不能打开ssl链接
date: 2016-12-17 08:43:52
tags:
- error
- python
- requests
- urllib
- urllib2
---

### SSL: CERTIFICATE\_VERIFY\_FAILED

#### python中不能打开ssl链接

```
- import requests.packages.urllib3.util.ssl_ requests.packages.urllib3.util.ssl_.DEFAULT_CIPHERS = ‘ALL'
- pip install requests
```

> [python-ssl\_error](http://stackoverflow.com/questions/31730819/python-sslerror-using-requests-for-surveymonkey-com)  
> 
> <!-- more -->

1.  使用ssl创建未经验证的上下文，在urlopen中传入上下文参数
    
    ```
    import ssl
    import urllib2
    
    # This restores the same behavior as before.
    context = ssl._create_unverified_context()
    print urllib2.urlopen("https://www.baidu.com", context=context).read()
    ```
    
2.  导入ssl时关闭全局证书验证
    
    ```
    import ssl
    import urllib2
    # Legacy Python that doesn't verify HTTPS certificates by default 
    ssl._create_default_https_context = ssl._create_unverified_context
    
    # Handle target environment that doesn't support HTTPS verification
    #ssl._create_default_https_context = _create_unverified_https_context
    
    print urllib2.urlopen("https://www.baidu.com").read()
    ```
    

> [官方文档介绍](https://www.python.org/dev/peps/pep-0476/)
