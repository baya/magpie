# -*- coding: utf-8 -*-

module Magpie

  class TenpayModel
    include Goose
    include Mouse

    set_accounts_kind :tenpay

    attr_accessor :cmdno,
    :date,
    :bank_type,
    :desc,
    :purchaser_id,
    :bargainor_id,
    :transaction_id,
    :sp_billno,
    :total_fee,
    :fee_type,
    :return_url,
    :attach,
    :spbill_create_ip,
    :sign

    goose_validate_presence_of :cmdno,
    :date,
    :bank_type,
    :desc,
    :bargainor_id,
    :transaction_id,
    :sp_billno,
    :total_fee,
    :fee_type,
    :return_url,
    :attach,
    :spbill_create_ip,
    :sign

    goose_validate_format_of :transaction_id,
    :allow_blank => true,
    :with        => /\A[0-9]{10}[0-9]{8}[0-9]{10}\Z/ ,
    :msg         => "格式错误,transaction_id为28位长的数值,其中前10位为商户网站编号(SPID)，由财付通统一分配;之后8位为订单产生的日期,如20050415;最后10位商户需要保证一天内不同的事务(用户订购一次商品或购买一次服务),其ID不相同"

    goose_validate_format_of :total_fee,
    :allow_blank => true,
    :with        => /^\d+$/,
    :msg         => "格式错误,只能为数字,以分为单位,不允许包含任何字符"

    IP_FORMAT = /\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/

    goose_validate_format_of :spbill_create_ip,
    :allow_blank => true,
    :with        => IP_FORMAT,
    :msg         => 'ip地址格式错误'

    goose_validate_length_of :sp_billno, :max_length => 28, :allow_blank => true, :msg => "长度错误,应该在28个字符内"

    goose_validate do |am|
      am.errors[:fee_type] << "目前只支持人民币,请填1" unless am.fee_type.blank? or am.fee_type.to_s == "1"
      am.errors[:sign] << "sign签名必须大写" unless am.sign.blank? or am.sign.upcase == am.sign
      am.errors[:sign] << "invalid sign" if am.invalid_request_sign?
      am.errors[:bargainor_id] << "商户编号不存在" if !am.partner.blank? and am.missing_partner?
    end


    def invalid_request_sign?
      text = %w(cmdno date bargainor_id transaction_id sp_billno total_fee fee_type return_url attach spbill_create_ip ).map{ |attr|
        "#{attr}=#{@attributes[attr]}" unless @attributes[attr].blank?
      }.join("&") + "&key=" + self.key.to_s
      Digest::MD5.hexdigest(text).upcase != self.sign ? true : false
    end

    def partner
      self.bargainor_id
    end

    def notify_sign
      text = %w(cmdno pay_result date transaction_id sp_billno total_fee fee_type attach).map{ |attr|
        "#{attr}=#{self.send(attr)}"
      }.join("&") + "&key=" + self.key.to_s
      Digest::MD5.hexdigest(text).upcase
    end

    def notify_url
      self.return_url
    end

    def notify
      @notify ||= { "cmdno" => cmdno,
        "pay_result"     => pay_result,
        "date"           => date,
        "transaction_id" => transaction_id,
        "sp_billno"      => sp_billno,
        "total_fee"      => total_fee,
        "fee_type"       => fee_type,
        "attach"         => attach,
        "sign"           => notify_sign
      }
    end

    def notify_string
      @n_str ||= notify.map{ |kv| "%s=%s" % kv }.join("&")
    end

    def pay_result
      @pay_result ||= "0"
    end


  end

end
