# -*- coding: utf-8 -*-

module Magpie

  class AlipayModel

    include Goose
    include Mouse

    set_accounts_kind :alipay

    attr_accessor :service, :partner, :notify_url, :return_url, :sign, :sign_type, :subject, :out_trade_no

    attr_accessor :payment_type, :show_url, :body, :price, :total_fee, :quantity, :seller_email, :seller_id

    attr_accessor :_input_charset

    goose_validate :presence_attributes, :length_attributes, :format_attributes do |am|
      am.errors[:money] << "price和total_fee不能同时出现" if am.repeat_money?
      am.errors[:money] << "price and total_fee can not both be blank" if am.money_blank?
      am.errors[:quantity] << "if price is not blank, must input quantity" if am.price_missing_quantity?
      am.errors[:seller] << "seller_email and seller_id can not both be blank" if am.seller_blank?
      am.errors[:sign] << "invalid sign" if am.invalid_sign?
      am.errors[:partner] << "not exist" if !am.partner.blank? and am.missing_partner?
      am.errors[:_input_charset] << "should be utf-8 or gb2312" unless am._input_charset.blank? or %w(utf-8 gb2312).member?(am._input_charset)
    end

    def repeat_money?
      self.price.to_s.length > 0 and self.total_fee.to_s.length > 0
    end

    def price_missing_quantity?
      self.price.to_s.length > 0 and self.quantity.blank?
    end

    def seller_blank?
      self.seller_id.blank? and self.seller_email.blank?
    end

    def money_blank?
      self.price.blank? and self.total_fee.blank?
    end

    def invalid_sign?
      attrs = @attributes.dup
      attrs.delete("sign")
      attrs.delete("sign_type")
      text = attrs.delete_if{ |k, v| v.blank? }.sort.collect{ |s| s[0] + "=" + URI.decode(s[1]) }.join("&") + self.key
      self.sign == Digest::MD5.hexdigest(text) ? false : true
    end

    def notify
      @notify ||= notify_attrs.inject({ }){ |notify, attr|
        notify[attr] = self.send(attr)
        notify
      }.merge("sign_type" => sign_type, "sign" => notify_sign)
    end


    private

    def notify_id
      @notify_id ||= Time.now.to_i
    end

    def notify_time
      @notify_time ||= Time.now.strftime("%Y-%m-%d %H:%M:%S")
    end

    def notify_sign
      @notify_sign ||= Digest::MD5.hexdigest(notify_text).downcase
    end

    def notify_text
      @notify_text ||= notify_attrs.sort.collect{ |attr|
        "#{attr}=#{self.send(attr)}"
      }.join("&") + self.key
    end

    def trade_no
      @trade_no ||= Time.now.to_i.to_s + rand(1000000).to_s
    end

    def trade_status
      @trade_status ||= %w(TRADE_FINISHED TRADE_SUCCESS)[rand(2)]
    end

    def notify_attrs
      @notify_attrs ||= %w{ notify_id
        notify_time
        trade_no
        out_trade_no
        payment_type
        subject
        body
        price
        quantity
        total_fee
        trade_status
        seller_email
        seller_id
        refund_status
        buyer_id
        gmt_create
        is_total_fee_adjust
        gmt_payment
        gmt_refund
        use_coupon
      }.select{ |attr| self.respond_to?(attr, true) && self.send(attr).to_s.length > 0 }
    end


    def presence_attributes
      [:service, :partner, :notify_url, :return_url, :sign, :sign_type, :subject, :out_trade_no, :payment_type].each {|attr|
        self.errors[attr] << "can't be blank" if self.send(attr).blank?
      }
    end

    def length_attributes
      errors[:partner] << length_error_msg(16) if self.partner.to_s.length > 16
      [:notify_url, :return_url].each { |attr| self.errors[attr] << length_error_msg(190) if self.send(attr).to_s.length > 190}
      errors[:show_url] << length_error_msg(400) if self.show_url.to_s.length > 400
      errors[:body] << length_error_msg(1000) if body.to_s.length > 1000
      errors[:out_trade_no] << length_error_msg(64) if out_trade_no.to_s.length > 64
      errors[:payment_type] << length_error_msg(4) if payment_type.to_s.length > 4
    end

    def format_attributes
      [:price, :total_fee].each { |attr|
        self.errors[attr] << "format should be Number(13, 2)" unless self.send(attr).blank? or self.send(attr) =~  /^[0-9]{1,9}\.[0-9]{1,2}$/
      }
      self.errors[:quantity] << "should be integer and between 1~999999" unless self.quantity.blank? or self.quantity =~ /^[1-9]{1,6}$/
    end

    def length_error_msg(length)
      "is too long (maximum is #{length} characters)"
    end

  end

end
