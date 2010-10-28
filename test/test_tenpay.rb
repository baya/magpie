# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__))
$:.unshift(File.dirname(__FILE__) + "/.." + "/lib")

require 'helper'

Magpie::TenpayModel.class_eval{ set_accounts_kind :tenpay, :env => ENV['magpie']}

class TenpayTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Magpie::BIRD_APP
  end

  def setup
    @accounts = YAML.load_file("test/partner.yml")["tenpay"]
    @params = { "cmdno" => "1",
      "date" => "20101025",
      "bargainor_id" => @accounts[0][0],
      "transaction_id" => "#{@accounts[0][0]}2010102512345678910",
      "sp_billno" => "1111",
      "total_fee" => "1200",
      "fee_type"  => 1,
      "return_url" => "http://ticket.fantong.com:3000/tenpay/notify_url",
      "attach" => "text",
      "spbill_create_ip" => "127.0.0.1"
    }
    @gateway = "/tenpay/cgi-bin/v3.0/payservice.cgi"
  end

  def test_return_xml
    get @gateway, @params
    assert last_response.ok?
    assert last_response.body.include? "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    assert last_response.headers["Content-type"], "text/xml"
    post @gateway, @params
    assert last_response.ok?
    assert last_response.body.include? "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    assert last_response.headers["Content-type"], "text/xml"
  end

  def test_validates_prensence
    post @gateway, { }
    %w(cmdno date bank_type desc bargainor_id transaction_id sp_billno total_fee
fee_type return_url attach spbill_create_ip sign).each do |attr|
       assert last_response.body.include? can_not_blank(attr)
    end
  end

  def test_validates_length
    post @gateway, @params.merge("sp_billno" => "a" * 30)
    assert last_response.body.include? "<sp_billno>长度错误,应该在28个字符内</sp_billno>"
    post @gateway, { }
    assert !last_response.body.include?("<sp_billno>长度错误,应该在28个字符内</sp_billno>")
  end

  def test_validates_format
    post @gateway, @params.merge("transaction_id" => "45aabb2008954321")
    assert last_response.body.include?(transaction_id_error_msg)
    post @gateway, { }
    assert !last_response.body.include?(transaction_id_error_msg)
    post @gateway, @params.merge("transaction_id" => "1234567890201010241234567890")
    assert !last_response.body.include?(transaction_id_error_msg)
    post @gateway, @params.merge("total_fee" => "10.2")
    assert last_response.body.include?(total_fee_error_msg)
    post @gateway, @params.merge("total_fee" => "100a")
    assert last_response.body.include?(total_fee_error_msg)
    post @gateway, @params.merge("total_fee" => "998")
    assert !last_response.body.include?(total_fee_error_msg)
    post @gateway, @params.merge("fee_type" => "2")
    assert last_response.body.include?(fee_type_error_msg)
    post @gateway, @params.merge("fee_type" => 1)
    assert !last_response.body.include?(fee_type_error_msg)
    post @gateway, @params.merge("spbill_create_ip" => "187.25.32")
    assert last_response.body.include?(spbill_create_ip_error_msg)
    post @gateway, @params.merge("spbill_create_ip" => "187.25.32.999")
    assert last_response.body.include?(spbill_create_ip_error_msg)
    post @gateway, @params.merge("spbill_create_ip" => "127.0.0.1")
    assert !last_response.body.include?(spbill_create_ip_error_msg)
  end

  def test_validates_sign
    post @gateway, @params.merge("sign" => "aaaaa")
    assert last_response.body.include?(sign_should_upcase)
    post @gateway, @params.merge("sign" => "AAAAA")
    assert !last_response.body.include?(sign_should_upcase)
    text = %w(cmdno date bargainor_id transaction_id sp_billno total_fee fee_type return_url attach spbill_create_ip ).map {|attr|
      "#{attr}=#{@params[attr]}" unless @params[attr].blank?
    }.join("&")
    invalid_sign = Digest::MD5.hexdigest(text).upcase
    post @gateway, @params.merge("sign" => invalid_sign)
    assert last_response.body.include?("<sign>invalid sign</sign>")
    sign = Digest::MD5.hexdigest(text + "&key=" + @accounts[0][1]).upcase
    post @gateway, @params.merge("sign" => sign)
    assert !last_response.body.include?("<sign>invalid sign</sign>")
  end

  def test_notify_sign
    am = Magpie::TenpayModel.new(@params)
    assert am.pay_result == "0"
    @params["pay_result"] = am.pay_result
     text = %w(cmdno pay_result date transaction_id sp_billno total_fee fee_type attach).map {|attr|
      "#{attr}=#{@params[attr]}" unless @params[attr].blank?
    }.join("&") + "&key=" + @accounts[0][1]
    sign = Digest::MD5.hexdigest(text).upcase
    assert_equal sign, am.notify_sign.upcase
  end

  private

  def can_not_blank(attr)
    "<#{attr}>can't be blank</#{attr}>"
  end

  def transaction_id_error_msg
    "<transaction_id>格式错误,transaction_id为28位长的数值,其中前10位为商户网站编号(SPID)，由财付通统一分配;之后8位为订单产生的日期,如20050415;最后10位商户需要保证一天内不同的事务(用户订购一次商品或购买一次服务),其ID不相同</transaction_id>"
  end

  def total_fee_error_msg
    "<total_fee>格式错误,只能为数字,以分为单位,不允许包含任何字符</total_fee>"
  end

  def fee_type_error_msg
    "<fee_type>目前只支持人民币,请填1</fee_type>"
  end

  def spbill_create_ip_error_msg
    "<spbill_create_ip>格式错误</spbill_create_ip>"
  end

  def sign_should_upcase
    "<sign>sign签名必须大写</sign>"
  end


end
