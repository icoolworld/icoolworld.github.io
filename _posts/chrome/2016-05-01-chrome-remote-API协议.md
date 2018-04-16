---
layout: post
title: chrome-remote-API协议
categories: chrome
---

# 基于chrome remote debug 调试抓取页面

> 现如今大多数页面，通过html5/js等方式，动态渲染页面，对于抓取动态网页，用常规的抓取方法显得力不从心。
前些年出现了phantomjs，可以有效的抓取动态页面，但phantomjs的一些缺点，内存溢出等经常出现卡死。现在该作者也停止更新phantomjs了

Now,决定弃用phantomjs!


> 发现新大陆

chrome自从v59版本后，推出了headless浏览器，配合Chrome DevTools Protocol，使用浏览器内核其Api，可实现分布远程调试chrome(数据抓取等)

Chrome DevTools Protocol允许工具对Chromium，Chrome和其他基于Blink的浏览器进行测试，检查，调试和配置。 许多现有项目目前使用该协议。 Chrome DevTools开发人员工具，使用此协议，团队维护其API。



## Server端，在装有chrome浏览器环境的服务器中，打开chrome  remote debug

> 以下命令在docker环境下,alpine,chrome环境中，更多chrome启动参数,参考https://peter.sh/experiments/chromium-command-line-switches/

```
chromium-browser --headless --no-sandbox --disable-gpu --remote-debugging-port=9222 

chrome --headless --no-sandbox --disable-gpu --remote-debugging-port=9222 --remote-debugging-address=0.0.0.0 --window-size=1920,1080 --user-data-dir=<some directory>

```


> 注意，这里使用的remote-debugging-port是9444，是在初始化启动命令中设置折。可以通过浏览器打开查看远程服务器中的chrome信息

http://192.168.110.128:9444/json
```
[
{
"description": "",
"devtoolsFrontendUrl": "/devtools/inspector.html?ws=192.168.110.128:9444/devtools/page/(9E4790959AAB0C8FB8F309ABB204729C)",
"id": "(9E4790959AAB0C8FB8F309ABB204729C)",
"title": "百度一下，你就知道",
"type": "page",
"url": "https://www.baidu.com/",
"webSocketDebuggerUrl": "ws://192.168.110.128:9444/devtools/page/(9E4790959AAB0C8FB8F309ABB204729C)"
},
{
"description": "",
"devtoolsFrontendUrl": "/devtools/inspector.html?ws=192.168.110.128:9444/devtools/page/(C8A6E4D304F820AC9F48AC9A34137F78)",
"id": "(C8A6E4D304F820AC9F48AC9A34137F78)",
"title": "百度一下，你就知道",
"type": "page",
"url": "https://www.baidu.com/",
"webSocketDebuggerUrl": "ws://192.168.110.128:9444/devtools/page/(C8A6E4D304F820AC9F48AC9A34137F78)"
},
{
"description": "",
"devtoolsFrontendUrl": "/devtools/inspector.html?ws=192.168.110.128:9444/devtools/page/(E18749BAD4802F598A844A7EE14BA9C4)",
"id": "(E18749BAD4802F598A844A7EE14BA9C4)",
"title": "about:blank",
"type": "page",
"url": "about:blank",
"webSocketDebuggerUrl": "ws://192.168.110.128:9444/devtools/page/(E18749BAD4802F598A844A7EE14BA9C4)"
},
{
"description": "",
"devtoolsFrontendUrl": "/devtools/inspector.html?ws=192.168.110.128:9444/devtools/page/(2C5CCAACD2BFBA9E39D73EBAB2291C87)",
"id": "(2C5CCAACD2BFBA9E39D73EBAB2291C87)",
"title": "",
"type": "page",
"url": "file:///",
"webSocketDebuggerUrl": "ws://192.168.110.128:9444/devtools/page/(2C5CCAACD2BFBA9E39D73EBAB2291C87)"
}
]
```

### 新建一个标签
```
http://localhost:9222/json/new
http://localhost:9222/json/new?http://www.baidu.com
```

### 关闭一个标签
```
http://localhost:9222/json/close/477810FF-323E-44C5-997C-89B7FAC7B158
```

### 激活标签页
```
http://localhost:9222/json/activate/477810FF-323E-44C5-997C-89B7FAC7B158
```

### 查看版本信息
```
http://localhost:9222/json/version
```


## client端，通过websocket协议，连接至chrome  remote port
```
ws://192.168.110.128:9444/devtools/page/(9E4790959AAB0C8FB8F309ABB204729C)
```

> 执行以下api接口中的命令

```
#打开页面
{"id":200,"method":"Page.navigate","params":{"url":"https://www.baidu.com"}}
#获取dom
{"id":200,"method":"DOM.getDocument"}
#获取html
{"id":200,"method":"DOM.getOuterHTML","params":{"nodeId":1,"backendNodeId":12}}
#获取资源树
{"id":200,"method":"Page.getResourceTree","params":{}}
```

## 通过Api接口(Runtime.evaluate)执行js,类似于chrome中的onsole输出
```
{"id":200,"method":"Runtime.evaluate","params":{"expression":"document.title","objectGroup":"console","includeCommandLineAPI":true,"silent":false,"contextId":1,"returnByValue":false,"generatePreview":true,"userGesture":true,"awaitPromise":false}}

{"id":200,"method":"Runtime.evaluate","params":{"expression":"document.title","objectGroup":"console","includeCommandLineAPI":true,"silent":false,"returnByValue":false,"generatePreview":true,"userGesture":true,"awaitPromise":false}}

返回结果
{
    "id": 200,
    "result": {
        "result": {
            "type": "string",
            "value": "百度一下，你就知道"
        }
    }
}


```


## Api功能模块域
```
https://chromedevtools.github.io/debugger-protocol-viewer/1-2/
```

## 扩展API
有很多扩展应用使用了该协议来与页面做交互调试，官网上有很多Sample Extensions
```
https://developer.chrome.com/extensions/samples#search:debugger
```

## Chrome Api
https://chromedevtools.github.io/devtools-protocol/

## API--模拟键盘输入
https://chromedevtools.github.io/devtools-protocol/tot/Input/

## chrome启动参数
https://peter.sh/experiments/chromium-command-line-switches/

## 一些有意思的工具
https://developer.chrome.com/devtools/docs/debugging-clients

## 后话

很多工具都使用了Chrome debugging protocol，包括phantomJS，Selenium的ChromeDriver，本质都是一样的实现，它就相当于Chrome内核提供的API让应用调用。

官网列出了很多有意思的工具：链接，因为API丰富，所以才有了这么多的chrome插件。

实现了Remote debugging protocol的node的库：

chrome-debug-protocol 使用了ES6和TypeScript https://github.com/DickvdBrink/chrome-debug-protocol
chrome-remote-interface 官网推荐的 https://github.com/cyrus-and/chrome-remote-interface
chrome-har-capturer 传入url，直接获取har format文件 https://github.com/cyrus-and/chrome-har-capturer

## 什么是WebDriver 
WebDriver是一个开源工具，用于在许多浏览器上自动测试web应用。它提供了导航到网页，用户输入，JavaScript执行等功能。
WebDriver W3C标准
https://w3c.github.io/webdriver/webdriver-spec.html

## 什么是chromedriver
ChromeDriver是一个独立的服务，它为Chromium实现[WebDriver's wire protocol 协议](https://github.com/SeleniumHQ/selenium/wiki/JsonWireProtocol "WebDriver's wire protocol 协议")
chromedriver正在实施并转向W3C标准。ChromeDriver适用于Android版Chrome和桌面版Chrome（Mac，Linux，Windows和ChromeOS）。

chromedriver已经实现的w3c标准功能
https://chromium.googlesource.com/chromium/src/+/master/docs/chromedriver_status.md

chromedriver由chromium team维护


## 使用Selenium驱动chromedriver
```
import time
#导入webdriver
from selenium import webdriver

#指定chromedriver的path位置
driver = webdriver.Chrome('/path/to/chromedriver')  # Optional argument, if not specified will search path.
driver.get('http://www.google.com/xhtml');
time.sleep(5) # Let the user actually see something!
search_box = driver.find_element_by_name('q')
search_box.send_keys('ChromeDriver')
search_box.submit()
time.sleep(5) # Let the user actually see something!
driver.quit()
```

## 控制chromedriver的生命周期 Controlling ChromeDriver's lifetime
ChromeDriver类在创建时启动ChromeDriver服务器进程，并在调用退出时终止它。 这可能会浪费大量时间用于大型测试套件，其中每个测试都会创建一个ChromeDriver实例。 

有两种方法可以解决这个问题：
1. Use the ChromeDriverService. This is available for most languages and allows you to start/stop the ChromeDriver server yourself. See here for a Java example (with JUnit 4):
```
@RunWith(BlockJUnit4ClassRunner.class)
public class ChromeTest extends TestCase {

  private static ChromeDriverService service;
  private WebDriver driver;

  @BeforeClass
  public static void createAndStartService() {
    service = new ChromeDriverService.Builder()
        .usingDriverExecutable(new File("path/to/my/chromedriver"))
        .usingAnyFreePort()
        .build();
    service.start();
  }

  @AfterClass
  public static void createAndStopService() {
    service.stop();
  }

  @Before
  public void createDriver() {
    driver = new RemoteWebDriver(service.getUrl(),
        DesiredCapabilities.chrome());
  }

  @After
  public void quitDriver() {
    driver.quit();
  }

  @Test
  public void testGoogleSearch() {
    driver.get("http://www.google.com");
    // rest of the test...
  }
}
```

python :
```
import time

from selenium import webdriver
import selenium.webdriver.chrome.service as service

service = service.Service('/path/to/chromedriver')
service.start()
capabilities = {'chrome.binary': '/path/to/custom/chrome'}
driver = webdriver.Remote(service.service_url, capabilities)
driver.get('http://www.google.com/xhtml');
time.sleep(5) # Let the user actually see something!
driver.quit()
```

2. Start the ChromeDriver server separately before running your tests, and connect to it using the Remote WebDriver.
Terminal:
```
$ ./chromedriver
Started ChromeDriver
port=9515
version=14.0.836.0
```

java:
```
WebDriver driver = new RemoteWebDriver("http://127.0.0.1:9515", DesiredCapabilities.chrome());
driver.get("http://www.google.com");
```


> https://div.io/topic/1464
> https://sites.google.com/a/chromium.org/chromedriver/
> https://github.com/SeleniumHQ/selenium/wiki/JsonWireProtocol
> 
> https://github.com/seleniumhq/selenium
> https://sites.google.com/a/chromium.org/chromedriver/getting-started
> 
> https://github.com/SeleniumHQ/selenium/wiki/DesiredCapabilities.md
> https://sites.google.com/a/chromium.org/chromedriver/capabilities
> http://peter.sh/examples/?/chromium-switches.html