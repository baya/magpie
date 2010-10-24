Magpie用于模拟支付平台的沙盒功能
=============================

**Git**:            [http://github.com/baya/magpie](http://github.com/baya/magpie)

**Author**:         Guimin Jiang

**Copyright**:      2010

**License**:        MIT License

**Latest Version**: 0.8.6.2

**Release Date**:   2010-10-20


快搭
----

    sudo gem install magpie
打开终端,输入:
    $ mag magpie.yml

magpie.yml文件用来配置你的商号信息, 假设你在支付宝有个账号:123456, key是:aaabbb, 网银在线有个账号:789789, key是:cccddd, 那么你在magpie.yml中这样写,

    alipay:
     - ["123456", "aaabbb"]

    chinabank:
     - ["789789", "cccddd"]

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

然后在你开发的商户系统中将支付网关由支付宝的网关`https://www.alipay.com/cooperate/gateway.do`更改为magpie的网关`http://127.0.0.1:9292/alipay`

如果你请求的参数出现错误, 你可以通过magpie的日志查看到详细的出错信息, 或者在浏览器上查看出错信息(以xml的格式显示)

如果你的支付请求成功, magpie将会模拟支付宝的主动通知模式, 给你的商户系统发送通知, 你需要确保发送给magpie的`notify_url`是可用的,

magpie将通过这个`notify_url`将支付成功的通知发到你的商户系统中, 这样你就可以避免去支付宝的页面进行真实的支付.

对于网银在线, 将支付网关由网银在线的网关`https://pay3.chinabank.com.cn/PayGate`更改为magpie的网关`http://127.0.0.1:9292/chinabank`


支持的支付平台
--------------

- 支付宝(alipay)
- 网银在线(chinabank)

使用的项目
--------
* [饭票](http://piao.fantong.com)
* [饭团](http://tuan.fantong.com)


感谢
----
* potian [Rack编程](http://www.javaeye.com/topic/605707)的作者
* liuzihua


Changelog
---------
- **2010-10-20**: 0.8.6.1 release
  - 支持网银在线

- **2010-10-20**: 0.8.6.2 release
  - 改善README.md的可阅读性



Copyright
---------

MAGPIE &copy; 2007-2010 by [Guimin Jiang](mailto:kayak.jiang@gmail.com).
MAGPIE is licensed under the MIT license except for some files which come
from the RDoc/Ruby distributions. Please see the {file:COPYING} documents for more information.





