# -*- coding: utf-8 -*-

module Magpie
  class ChinabankModel

    include Goose

    attr_accessor :v_mid, :v_oid, :v_amount, :v_moneytype, :v_url, :v_md5info, :remark1, :remark2

    goose_validate :presence_attributes

    goose_validate do |am|
      am.errors[:sign] << "invalid v_md5info" if am.invalid_sign?
      am.errors[:v_oid] << "is too long (maximum is 64 characters)" if am.v_oid.to_s.length > 64
      am.errors[:v_url] << "is too long (maximum is 200 characters)" if am.v_url.to_s.length > 200
      am.errors[:v_amount] << "format should be Number(6, 2)" unless am.v_amount =~ /^[0-9]{1,6}\.[0-9]{1,2}$/ or am.v_amount.blank?
    end

    def invalid_sign?
      text = @attributes["v_amount"]+@attributes["v_moneytype"]+@attributes["v_oid"]+@attributes["v_mid"]+@attributes["v_url"]+self.key
      self.sign.upcase == Digest::MD5.hexdigest(text).upcase ? false : true
    rescue => e
      true
    end

    def sign
      self.v_md5info
    end

    def partner
      self.v_mid
    end

    # 商家系统用来处理网银支付结果的url
    def notify_url
      self.v_url
    end

    def account
      @account ||= self.class.accounts.assoc self.partner
      @account ||= []
    end


    def key
      self.account[1].to_s
    end

    def self.accounts
      @accounts ||= YAML.load_file('test/partner.yml')['chinabank'] if ENV['magpie'] == 'test'
      @accounts ||= Magpie.yml_db['chinabank']
    end

    def notify
      @notify ||= { "v_oid" => v_oid,
        "v_pstatus"   => v_pstatus,
        "v_amount"    => v_amount,
        "v_pstring"   => v_pstring,
        "v_pmode"     => v_pmode,
        "v_moneytype" => v_moneytype,
        "v_md5str"    => notify_sign,
        "remark1"     => remark1,
        "remark2"     => remark2
      }.delete_if { |k, v| v.to_s.length == 0}
    end


    private
    def notify_sign
      @notify_sign ||= Digest::MD5.hexdigest(notify_text).upcase
    end

    def v_pstatus
      "20"
    end

    def v_pstring
      "支付完成"
    end

    def v_pmode
      banks = %w{ 工商银行 招商银行 建设银行 光大银行 交通银行}
      banks[rand(banks.size)]
    end

    def notify_text
      @notify_text ||= v_oid + v_pstatus + v_amount + v_moneytype + key
    rescue => e
      "invalid sign"
    end

    def presence_attributes
      [:v_mid, :v_oid, :v_amount, :v_moneytype, :v_url, :v_md5info].each { |attr|
        errors[attr] << "can't be blank" if self.send(attr).blank?
      }
    end

  end

end
