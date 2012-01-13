# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__))
$:.unshift(File.dirname(__FILE__) + "/.." + "/lib")

require 'helper'

Magpie::AlipayModel.class_eval{ set_accounts_kind :alipay, :env => ENV['magpie']}

class AlipayTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Magpie::SNAKE_APP
  end

  def setup
    @params = { "service" => "create_direct_pay_by_user", "sign" => "" }
    @gateway = "/alipay"
    @accounts = YAML.load_file('test/partner.yml')['alipay']
  end

  def test_return_xml
    get @gateway, @params
    assert last_response.ok?
    assert_equal last_response.headers["Content-type"], "text/html"
  end

  def test_validates_prensence
    get @gateway, @params.merge("service"      => "",
                                "notify_url"   => "",
                                "partner"      => "",
                                "return_url"   => "",
                                "sign"         => "",
                                "sign_type"    => "",
                                "subject"      => "",
                                "out_trade_no" => "",
                                "payment_type" => "")
    assert last_response.body.include? can_not_blank_error_msg
  end


  def test_validates_length
    get @gateway, @params.merge("partner" => "200910082009100820091008", "payment_type" => "123abc")
    assert last_response.body.include? partner_too_long_error_msg
    assert last_response.body.include? payment_type_too_long_error_msg
  end


  def test_validates_repeat_money
    get @gateway, @params.merge("price" => 10.00, "total_fee" => 20.00)
    assert last_response.body.include? price_and_total_fee_confict_error_msg
  end


  def test_validates_numericality
    get @gateway, @params.merge("quantity" => 0)
    assert last_response.body.include? quantity_format_error_msg
    get @gateway, @params.merge("quantity" => 1.2)
    assert last_response.body.include? quantity_format_error_msg
    get @gateway, @params.merge("quantity" => 10000000)
    assert last_response.body.include? quantity_format_error_msg
  end


  def test_validates_format
    get @gateway, @params.merge("price" => 10.002, "total_fee" => 100)
    assert last_response.body.include? price_format_error_msg
    assert last_response.body.include? total_fee_error_msg
  end


  def test_validates_if_missing_quantity
    get @gateway, @params.merge("price" => "10.00", "quantity" => "")
    assert last_response.body.include? price_not_blank_error_msg
  end


  def test_validates_if_money_blank
    get @gateway, @params.merge("price" => "", "total_fee" => "")
    assert last_response.body.include? price_and_total_fee_both_blank_error_msg
  end

  def test_validates_seller_blank
    get @gateway, @params.merge("seller_id" => "", "seller_email" => "")
    assert last_response.body.include? "seller_email and seller_id can not both be blank"
  end

  def test_validates_charset
    get @gateway, @params.merge("_input_charset" => "utf-9")
    assert last_response.body.include? charset_error_msg
    get @gateway, @params.merge("_input_charset" => "utf-8")
    assert !last_response.body.include?(charset_error_msg)
    get @gateway, @params.merge("_input_charset" => "gb2312")
    assert !last_response.body.include?(charset_error_msg)
  end

  def test_validates_partner
    get @gateway, @params.merge("partner" => "test12348")
    assert last_response.body.include?(partner_not_exist_error_msg)
    get @gateway, @params.merge("partner" => "test123")
    assert !last_response.body.include?(partner_not_exist_error_msg)
  end

  def test_validates_sign
    account = @accounts[0]
    text = @params.sort.collect{ |s| s[0] + "=" + s[1].to_s}.join("&") + account[1]
    sign = Digest::MD5.hexdigest(text)
    get @gateway, @params.merge("sign" => sign, "partner" => account[0])
    assert last_response.body.include? invalid_sign_error_msg
    params = @params.dup
    params.delete("sign")
    params.delete("sign_type")
    text = params.merge("partner" => account[0]).delete_if{ |k, v| v.to_s.length == 0 }.sort.collect{ |s| s[0] + "=" + s[1].to_s }.join("&") + account[1]
    sign = Digest::MD5.hexdigest(text)
    get @gateway, @params.merge("sign" => sign, "partner" => account[0])
    assert !last_response.body.include?(invalid_sign_error_msg)
  end


  def test_gen_notify
    am = get_am
    notify = am.notify
    assert notify["sign_type"] == "MD5"
    assert notify["subject"] == "testPPP"
    assert notify["out_trade_no"] == "123456789"
    assert notify["payment_type"] == "1"
    assert notify["body"] == "koPPP"
    assert notify["total_fee"].to_s == "32.0"
    assert notify["seller_email"] == "test@fantong.com"
    assert !notify.has_key?("quantity")
    assert !notify.has_key?("_input_charset")
    assert !notify.has_key?("partner")
    assert notify.has_key?("sign")
    assert notify["sign"].is_a? String
    assert am.send(:notify_text) =~ /subject=/
    assert am.send(:notify_text) =~ /out_trade_no=/
    assert am.send(:notify_text) =~ /payment_type=/
    assert am.send(:notify_text) =~ /body=/
    assert am.send(:notify_text) =~ /total_fee=/
    assert am.send(:notify_text) =~ /seller_email=/
    assert am.send(:notify_text) != /quantity=/
  end

  def test_notify_sign
    am = get_am
    raw_h = notify_params
    raw_sign = am.send :notify_sign
    raw_h.delete("partner")
    raw_h.delete("sign_type")
    raw_h.delete("return_url")
    raw_h.delete("notify_url")
    raw_h.delete("_input_charset")
    raw_h.delete_if { |k, v| v.to_s.length == 0}
    raw_h.merge!("notify_id" => am.send(:notify_id),
                 "notify_time" => am.send(:notify_time),
                 "trade_no" => am.send(:trade_no),
                 "trade_status" => am.send(:trade_status)
                 )
    md5_str = Digest::MD5.hexdigest((raw_h.sort.collect{|s|s[0]+"="+s[1].to_s}).join("&")+am.key).downcase
    assert_equal raw_sign, md5_str
  end


  private

  def get_am
    am = Magpie::AlipayModel.new(:partner => "test123",
                                 :notify_url => "http://ticket.fantong.com:3000/alipay/notify",
                                 :return_url => "http://ticket.fantong.com:3000/alipay/feedback",
                                 :sign_type => "MD5",
                                 :subject => "testPPP",
                                 :out_trade_no => "123456789",
                                 :payment_type => "1",
                                 :body => "koPPP",
                                 :total_fee => 32.0,
                                 :seller_email => "test@fantong.com",
                                 :_input_charset => "utf-8",
                                 :quantity => "")
  end

  def notify_params
    { "partner" => "test123",
      "notify_url" => "http://localhost:3000/alipay/notify",
      "return_url" => "http://localhost:3000/alipay/feedback",
      "sign_type" => "MD5",
      "subject" => "testPPP",
      "out_trade_no" => "123456789",
      "payment_type" => "1",
      "body" => "koPPP",
      "total_fee" => 32.0,
      "seller_email" => "test@fantong.com",
      "_input_charset" => "utf-8",
      "quantity" => ""}
  end


  def can_not_blank_error_msg
    "can't be blank"
  end

  def partner_too_long_error_msg
    "is too long (maximum is 16 characters)"
  end

  def payment_type_too_long_error_msg
    "is too long (maximum is 4 characters)"
  end

  def price_and_total_fee_confict_error_msg
    "price和total_fee不能同时出现"
  end

  def quantity_format_error_msg
    "should be integer and between 1~999999"
  end

  def price_format_error_msg
    "format should be Number(13, 2)"
  end

  def total_fee_error_msg
    "format should be Number(13, 2)"
  end

  def price_not_blank_error_msg
    "if price is not blank, must input quantity"
  end

  def price_and_total_fee_both_blank_error_msg
    "price and total_fee can not both be blank"
  end

  def charset_error_msg
    "should be utf-8 or gb2312"
  end

  def partner_not_exist_error_msg
    "not exist"
  end

  def invalid_sign_error_msg
    "invalid sign"
  end

end
