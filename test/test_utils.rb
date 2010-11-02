# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__))
$:.unshift(File.dirname(__FILE__) + "/.." + "/lib")

require 'helper'

class Magpie::UtilsTest < Test::Unit::TestCase
  include Magpie::Utils


  def test_send_notify_timeout
    url = "bad_url"
    res = send_notify("post", url, "")
    assert res.is_a?(String)
    assert res.include?("请确认#{url}在你的商户系统中可用")
  end

  def test_send_notify_code
    url = "http://piao.fantong.com/alipay/notify"
    res = send_notify("POST", url, { })
    assert res.include?("fail")
    url = "http://piao.fantong.com/alipay/page_not_exit"
    res = send_notify("post", url, { })
    assert res.include?("请确认#{url}在你的商户系统中可用")
    url = "http://piao.fantong.com/chinabank/feedback"
    res = send_notify("post", url, { })
    assert res.include?("redirected")
    url = "http://piao.fantong.com/tenpay/notify"
    res = send_notify("post", url, { })
    assert res.include?("请确认#{url}在你的商户系统中可用")
    res = send_notify("get", url, "")
    assert !res.include?("请确认#{url}在你的商户系统中可用")
  end

end
