# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__))
$:.unshift(File.dirname(__FILE__) + "/.." + "/lib")

require 'helper'


Magpie::ChinabankModel.class_eval{ set_accounts_kind :chinabank, :env => ENV['magpie']}
class ChinabankTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Magpie::SNAKE_APP
  end

  def setup
    @gateway = "/chinabank"
    @params = {
      "v_mid"       => "20000400",
      "v_oid"       => "12345678",
      "v_amount"    => "1.00",
      "v_moneytype" => "CNY",
      "v_url"       => "http://localhost:3000/chinabank/feedback",
      "remark2"     => "[url:=http://piao.fantong.com/chinabank/notify]"
    }
    @accounts = YAML.load_file('test/partner.yml')['chinabank']
  end

  def test_return_xml
    post @gateway, @params
    assert last_response.ok?
    assert last_response.headers["Content-type"], "text/html"
  end

  def test_validates_prensence
    post @gateway, @params.dup.clear
    assert last_response.body.include? "can't be blank"
  end

  def test_validates_length
    post @gateway, @params.merge("v_oid" => "a" * 68,
                                 "v_url" => "http://test.com/" + "a" * 200)
    assert last_response.body.include? v_oid_too_long_error_msg
    assert last_response.body.include? v_url_too_long_error_msg
  end


  def test_validates_partner
    post @gateway, @params.merge("v_mid" => "fake123")
    assert last_response.body.include? v_mid_not_exist_error_msg
    post @gateway, @params.merge("v_mid" => "20000400")
    assert !last_response.body.include?(v_mid_not_exist_error_msg)
  end

  def test_validates_numericality
    post @gateway, @params.merge("v_amount" => -1.00)
    assert last_response.body.include? v_amount_format_error_msg
  end

  def test_validates_sign
    account = @accounts[0]
    text = @params["v_amount"]+@params["v_moneytype"]+@params["v_oid"]+@params["v_mid"]+@params["v_url"]
    md5_str = Digest::MD5.hexdigest(text+"errorkey")
    post @gateway, @params.merge("v_md5info" => md5_str)
    assert last_response.body.include?(invalid_md5_error_msg)
    md5_str = Digest::MD5.hexdigest(text+account[1])
    post @gateway, @params.merge("v_md5info" => md5_str)
    assert !last_response.body.include?(invalid_md5_error_msg)
  end


  def test_key
    am = Magpie::ChinabankModel.new(@params)
    assert am.key.length > 0
  end

  def test_notify_sign
    am = Magpie::ChinabankModel.new(@params)
    raw_hash = @params.dup
    raw_sign = am.send :notify_sign
    raw_hash.delete("remark2")
    raw_hash.merge!("v_pstatus" => am.send(:v_pstatus))
    md5_str = Digest::MD5.hexdigest(raw_hash["v_oid"] + raw_hash["v_pstatus"] + raw_hash["v_amount"] + raw_hash["v_moneytype"] + am.key)
    assert_equal raw_sign, md5_str.upcase
  end

  def test_notify
    am = Magpie::ChinabankModel.new(@params)
    assert am.notify.has_key?("v_oid")
    assert am.notify.has_key?("v_pmode")
    assert am.notify.has_key?("v_pstring")
    assert am.notify.has_key?("v_md5str")
    assert am.notify.has_key?("v_amount")
    assert am.notify.has_key?("v_pstatus")
    assert !am.notify.has_key?("remark1")
  end


  def v_oid_too_long_error_msg
    "is too long (maximum is 64 characters)"
  end

  def v_url_too_long_error_msg
    "is too long (maximum is 200 characters)"
  end

  def v_mid_not_exist_error_msg
    "商户编号不存在"
  end

  def v_amount_format_error_msg
    "format should be Number(6, 2)"
  end

  def invalid_md5_error_msg
    "invalid v_md5info"
  end

end
