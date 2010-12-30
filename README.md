Magpie用于模拟支付平台的沙盒功能
=============================

**Git**:            [http://github.com/baya/magpie](http://github.com/baya/magpie)

**Author**:         Guimin Jiang

**Copyright**:      2010

**License**:        MIT License

**Latest Version**: 0.8.8

**Release Date**:   2010-11-03


快搭
----

    sudo gem install magpie
打开终端,输入:
    $ mag magpie.yml

magpie.yml文件用来配置你的商号信息, 假设你在支付宝(alipay)有个账号:123456, key是:aaabbb, 网银在线(chinabank)
有个账号:789789, key是:cccddd, 财付通(tenpay)有个账号:888666, key是:dddggg, 那么你在magpie.yml中这样写,

    alipay:
     - ["123456", "aaabbb"]

    chinabank:
     - ["789789", "cccddd"]

    tenpay:
     - ["888666", "dddggg"]

**注意!** 如果你输入mag命令报错, 那可能是因为你的电脑缺少一些magpie需要的gem包, 试着使用下面的命令:

    $ sudo gem install rack
    $ sudo gem install hpricot

mag命令默认会在本地9292端口启动http服务, 你可以用-p选项指定端口

    mag -p 2010 magpie.yml

mag命令的更多选项可以通过`mag -h`查看

使用示例
-------

假设你正在实现支付宝支付的相关代码, 首先启动magpie服务

    $ mag magpie.yml

上面命令的意思是:用Mongrel启动magpie服务, 服务的mode是snake, 日志文件是magpie.log, 服务的端口是9292

完整的命令是: mag -s mongrel -M snake -L magpie.log -p 9292 magpie.yml

然后在你开发的商户系统中将支付网关由支付宝的网关`https://www.alipay.com/cooperate/gateway.do`

更改为magpie的网关`http://127.0.0.1:9292/alipay`

如果你请求的参数出现错误, 你可以通过magpie的日志查看到详细的出错信息, 或者在浏览器上查看出错信息

如果你的支付请求成功, magpie将会显示一个成功订单的页面, 然后你点击购买就可以给你自己的商户系统发送

购买成功的通知了, 你需要确保你商户系统的`notify_url`是可用的,magpie将通过这个`notify_url`将支付

成功的通知发到你的商户系统中, 这样你就可以避免去支付宝的页面进行真实的支付.

对于网银在线(chinabank), 将支付网关由网银在线的网关`https://pay3.chinabank.com.cn/PayGate`更改为

magpie的网关`http://127.0.0.1:9292/chinabank`

对于财付通(tenpay), 将支付网关由财付通的网关`http://service.tenpay.com/cgi-bin/v3.0/payservice.cgi`

更改为magpie的网关`http://127.0.0.1:9292/tenpay`


Magpie启动模式
-------------

**1. bird mode**

   $ mag -M bird magpie.yml

写ruby代码的人一般都是测试控, 这个bird模式主要是为他们提供.以支付宝(alipay)为例, 开发者将支付

参数提交到http://127.0.0.1:9292/alipay, 出错信息将以xml格式反馈给开发者,如果提交成功, 成功

信息同样以xml格式反馈给开发者, 同时magpie会自动将购买成功的消息通知到开发者的商户系统中,并返回

商户系统的处理结果.

在bird模式下,开发者需要确保magpie.yml中的商号信息是真实有效的,也就是在alipay上实际注册过的,因为

magpie在bird模式下会将开发者提交的支付参数往alipay的实际网关`https://www.alipay.com/cooperate/gateway.do`

发送一次.

网银在线(chinabank), 财付通(tenpay)的模拟情况与之类似.


**2. snake mode**

   $ mag -M snake

这是magpie默认的启动模式,以支付宝(alipay)为例, 开发者将支付参数提交到http://127.0.0.1:9292/alipay

出错信息以普通html页面显示,如果提交成功, 开发者将看到订单的详细信息, 然后开发者可以点击支付按钮进行支付

测试, 最终magpie将返回开发者商户系统的处理结果.

网银在线(chinabank), 财付通(tenpay)的模拟情况与之类似


其他语言开发者
------------

如果你使用其他开发语言, 比如php, java等,需要使用magpie, 必须首先搭建ruby执行环境才能运行mapgie.

你可以看看这篇资料[http://www.javaeye.com/topic/43228](http://www.javaeye.com/topic/43228)

在这篇资料,你看到"然后就可以安装rails了，"这里就可以停止了, 然后开始搭建ruby执行环境. 我鼓励你能

把整篇资料看完, 搭建好ruby on rails开发环境, 这样你就可以用rails开发项目了.




支持的支付平台
--------------

- 支付宝(alipay)
- 网银在线(chinabank)
- 财付通(tenpay)

使用的项目
--------
* [饭票](http://piao.fantong.com)
* [饭团](http://tuan.fantong.com)
* [套餐](http://tc.fantong.com)


感谢
----
* potian [Rack编程](http://www.javaeye.com/topic/605707)的作者
* liuzihua liuzihua8@gmail.com


Changelog
---------
- **2010-10-20**: 0.8.6.1 release
  - 支持网银在线

- **2010-10-20**: 0.8.6.2 release
  - 改善README.md的可阅读性

- **2010-11-03**: 0.8.8 release
  - 增加财付通的支持
  - 增加snake, bird两个启动模式
  - 增加日志功能

- **2010-11-08**: 0.8.8.1 release
  - 修改一个紧急bug: 加载yml文件报无法找到YAML


Copyright
---------

MAGPIE &copy; 2007-2010 by [Guimin Jiang](mailto:kayak.jiang@gmail.com).
MAGPIE is licensed under the MIT license except for some files which come
from the RDoc/Ruby distributions. Please see the {file:COPYING} documents for more information.





