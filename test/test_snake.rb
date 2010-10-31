# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__))
$:.unshift(File.dirname(__FILE__) + "/.." + "/lib")

require 'helper'

Magpie::AlipayModel.class_eval{ set_accounts_kind :alipay, :env => ENV['magpie']}
Magpie::TenpayModel.class_eval{ set_accounts_kind :tenpay, :env => ENV['magpie']}
Magpie::ChinabankModel.class_eval{ set_accounts_kind :chinabank, :env => ENV['magpie']}

class SnakeTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Magpie::SNAKE_APP
  end

  def test_return_html
    get "/alipay", { }
    assert last_response.ok?
    assert_equal last_response.headers["Content-type"], "text/html"
  end

  def test_alipay_index
    get "/alipay", { }
    assert last_response.body.include?("请求失败")
  end

  def test_tenpay_index
    get "/tenpay", { }
    assert last_response.body.include?("请求失败")
    post "/tenpay", { }
    assert last_response.body.include?("请求失败")
  end

  def test_chinabank_index
    get "/chinabank", { }
    assert last_response.body.include?("请求失败")
    post "/chinabank", { }
    assert last_response.body.include?("请求失败")
  end

  def test_static_file
    get "/images/errors.gif"
    #assert last_response.ok?
    #assert last_response.body.size > 0
  end

  def test_order_pay
    post "/order/pay", { "a" => "test"}
    assert last_response.status == 500
    assert last_response.body.include?("500")
  end

end
