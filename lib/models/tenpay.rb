# -*- coding: utf-8 -*-

module Magpie

  class TenpayModel
    include Goose

    attr_accessor :cmdno, :date, :bank_type, :desc, :purchaser_id, :bargainor_id, :transaction_id, :sp_billno

    attr_accessor :total_fee, :fee_type, :return_url, :attach, :spbill_create_ip, :sign

    goose_validate_presence_of :cmdno, :date, :bank_type, :desc, :bargainor_id, :transaction_id, :sp_billno

    goose_validate_presence_of :total_fee, :fee_type, :return_url, :attach, :spbill_create_ip, :sign

    goose_validate_format_of :transaction_id,
    :allow_blank => true,
    :with        => /^[0-9]{10}[0-9]{8}[0-9]{10}$/ ,
    :msg         => "格式错误,transaction_id为28位长的数值,其中前10位为商户网站编号(SPID)，由财付通统一分配;之后8位为订单产生的日期,如20050415;最后10位商户需要保证一天内不同的事务(用户订购一次商品或购买一次服务),其ID不相同"

    goose_validate_format_of :total_fee,
    :allow_blank => true,
    :with        => /^\d+$/,
    :msg         => "格式错误,只能为数字,以分为单位,不允许包含任何字符"

    goose_validate_length_of :sp_billno, :max_length => 28, :allow_blank => true, :msg => "长度错误,应该在28个字符内"

    goose_validate do |am|
      am.errors[:fee_type] << "目前只支持人民币,请填1" unless am.send(:fee_type).blank? or am.send(:fee_type).to_s == "1"
    end


  end

end
