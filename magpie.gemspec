# -*- coding: utf-8 -*-
Gem::Specification.new do |s|
  s.name            = "magpie"
  s.version         = "0.8.8.1"
  s.platform        = Gem::Platform::RUBY
  s.summary         = "用ruby语言编写的支付平台测试沙盒"

  s.description = <<-EOF
Magpie提供了支付宝(alipay), 网银在线(chinabank), 财付通(tenpay)的沙盒功能.使用Magpie, 开发人员可以测试商户系统提交到支付平台的参数是否正确, 并且当参数提交出错时, 可以获知详细的错误信息;
Magpie模拟了各个支付平台的主动通知交互模式,这个功能可以使开发人员不必去支付平台的页面进行真实的支付,而通过Magpie就可以取得支付成功的效果,这样就可以轻松快速地对自己所开发的商户系统进行测试.
EOF

  #s.files            = Dir["{bin/*,lib/magpie/**/*,lib/*,lib/models/*,lib/middles/*,test/**/*}"] - %w(lib/magpie.yml lib/mag) +
  %w(COPYING magpie.gemspec README.md Rakefile )
  s.files            =%w(
bin/mag
static/images
static/images/error.gif
static/images/q2.gif
doc/css
doc/css/full_list.css
doc/css/style.css
doc/css/common.css
doc/index.html
doc/js
doc/js/app.js
doc/js/jquery.js
doc/js/full_list.js
doc/frames.html
doc/file_list.html
doc/_index.html
doc/method_list.html
doc/file.README.html
doc/top-level-namespace.html
doc/class_list.html
doc/Magpie
doc/Magpie/Goose.html
doc/Magpie/Server
doc/Magpie/Server/Options.html
doc/Magpie/Utils.html
doc/Magpie/Tenpay.html
doc/Magpie/Goose
doc/Magpie/Goose/ClassMethods.html
doc/Magpie/Alipay.html
doc/Magpie/Chinabank.html
doc/Magpie/Dung.html
doc/Magpie/ChinabankModel.html
doc/Magpie/Snake.html
doc/Magpie/Server.html
doc/Magpie/AlipayModel.html
doc/Magpie/Mouse
doc/Magpie/Mouse/MouseError.html
doc/Magpie/Mouse/ClassMethods.html
doc/Magpie/TenpayModel.html
doc/Magpie/Mothlog.html
doc/Magpie/Rubber.html
doc/Magpie/Mouse.html
doc/Magpie.html
lib/magpie/mouse.rb
lib/magpie/server.rb
lib/magpie/utils.rb
lib/magpie/goose.rb
lib/magpie/rubber.rb
lib/middles
lib/models
lib/magpie.rb
lib/magpie
lib/apps.rb
lib/models/dung.rb
lib/models/alipay.rb
lib/models/chinabank.rb
lib/models/tenpay.rb
lib/middles/alipay.rb
lib/middles/snake.rb
lib/middles/chinabank.rb
lib/middles/tenpay.rb
lib/views
lib/views/fail.html.erb
lib/views/success.html.erb
lib/views/layouts
lib/views/layouts/app.html.erb
test/partner.yml
test/test_alipay.rb
test/test_tenpay.rb
test/helper.rb
test/test_utils.rb
test/test_chinabank.rb
test/test_dung.rb
test/test_snake.rb
test/test_object.rb
test/test.log
COPYING
magpie.gemspec
README.md
Rakefile
)
  s.bindir           = 'bin'
  s.executables      << 'mag'
  s.require_paths    = ["lib"]
  s.has_rdoc         = 'yard'
  s.extra_rdoc_files = ['README.md']
  s.test_files       = Dir['test/test_*.rb']
  s.homepage         = 'http://github.com/baya/magpie'
  s.author           = 'jiangguimin'
  s.email            = 'kayak.jiang@gmail.com'
end
