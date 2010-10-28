# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__))
$:.unshift(File.dirname(__FILE__) + "/.." + "/lib")

require 'helper'

Magpie::AlipayModel.class_eval{ set_accounts_kind :alipay, :env => ENV['magpie']}
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

  def test_alipay_pay
    post "/alipay", { }
    assert last_response.ok?
  end

end
