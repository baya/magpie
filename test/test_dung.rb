# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__))
$:.unshift(File.dirname(__FILE__) + "/.." + "/lib")

require 'helper'

Magpie::AlipayModel.class_eval{ set_accounts_kind :alipay, :env => ENV['magpie']}
module Magpie
  class DungTest < Test::Unit::TestCase

    def setup
      @alipay = AlipayModel.new(:total_fee => 10, :subject => "测试商品", :out_trade_no => "123", :price => "100", :notify_url => "http://dog.com")
      @tenpay = TenpayModel.new(:total_fee => 200, :desc => "测试商品", :transaction_id => "123", :total_fee => "10000", :return_url => "http://dog.com")
      @chinabank = ChinabankModel.new(:v_amount => 100, :v_oid => "123", :v_amount => "100", :v_url => "http://dog.com")
    end


    def test_total_fee
      dung = Dung.new(@alipay)
      assert dung.total_fee == @alipay.total_fee
      dung = Dung.new(@tenpay)
      assert_equal dung.total_fee, @tenpay.total_fee.to_f/100
      dung = Dung.new(@chinabank)
      assert_equal dung.total_fee, @chinabank.v_amount
    end

    def test_subject
      dung = Dung.new(@alipay)
      assert dung.subject == @alipay.subject
      dung = Dung.new(@tenpay)
      assert dung.subject == @tenpay.desc
      dung = Dung.new(@chinabank)
      assert dung.subject.nil?
    end

    def test_trade_kind
      dung = Dung.new(@alipay)
      assert_equal dung.trade_kind, "即时到帐交易"
      dung = Dung.new(@tenpay)
      assert_equal dung.trade_kind, "即时到帐交易"
      dung = Dung.new(@chinabank)
      assert_equal dung.trade_kind, "即时到帐交易"
    end

    def test_trade_no
      assert_equal Dung.new(@alipay).trade_no, @alipay.out_trade_no
      assert_equal Dung.new(@tenpay).trade_no, @tenpay.transaction_id
      assert_equal Dung.new(@chinabank).trade_no, @chinabank.v_oid
    end

    def test_price
      assert_equal Dung.new(@alipay).price, @alipay.price
      assert_equal Dung.new(@tenpay).price, @tenpay.total_fee.to_f/100
      assert_equal Dung.new(@chinabank).price, @chinabank.v_amount
    end

    def test_notify_url
      assert_equal Dung.new(@alipay).notify_url, @alipay.notify_url
      assert_equal Dung.new(@alipay).notify_url, "http://dog.com"
      assert_equal Dung.new(@tenpay).notify_url, @tenpay.notify_url
      assert_equal Dung.new(@tenpay).notify_url, "http://dog.com"
      assert_equal Dung.new(@chinabank).notify_url, @chinabank.notify_url
      assert_equal Dung.new(@chinabank).notify_url, "http://dog.com"
    end

    def test_notify_to_query
      assert Dung.new(@alipay).notify_to_query.index("&")
      assert Dung.new(@tenpay).notify_to_query.index("&")
      assert Dung.new(@chinabank).notify_to_query.index("&")
    end

    def test_dung_kind
      assert Dung.new(@alipay).kind == "alipay"
      assert Dung.new(@tenpay).kind == "tenpay"
      assert Dung.new(@chinabank).kind == "chinabank"
    end

  end

end
