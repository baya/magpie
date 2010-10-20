# -*- coding: utf-8 -*-

class AlipayModel
  include ActiveModel::Validations
  attr_accessor :service,
  :partner,
  :notify_url,
  :return_url,
  :sign,
  :sign_type,
  :subject,
  :out_trade_no,
  :payment_type,
  :show_url,
  :body,
  :price,
  :total_fee,
  :quantity,
  :seller_email,
  :seller_id,
  :_input_charset

  validates_presence_of :service, :partner, :notify_url, :return_url, :sign, :sign_type, :subject, :out_trade_no, :payment_type
  validates_length_of :partner, :maximum => 16
  validates_length_of :notify_url, :return_url, :maximum => 190
  validates_length_of :show_url, :maximum => 400
  validates_length_of :body, :maximum => 1000
  validates_length_of :out_trade_no, :maximum => 64
  validates_length_of :payment_type, :maximum => 4
  validates_format_of :price, :total_fee,
  :with => /^[0-9]{1,9}\.[0-9]{1,2}$/,
  :allow_blank => true,
  :message => "format should be Number(13, 2)"
  validates_numericality_of :price, :total_fee,
  :greater_than_or_equal_to => 0.01,
  :less_than_or_equal_to => 100000000.00,
  :allow_blank => true,
  :message => "should between 0.01~100000000.00"
  validates_numericality_of :quantity,
  :only_integer => true,
  :greater_than => 0,
  :less_than => 1000000,
  :allow_blank => true,
  :message => "should be integer and between 1~999999"
  validates_inclusion_of :_input_charset, :in => %w(utf-8 gb2312), :message => "should be utf-8 or gb2312", :allow_blank => true

  validate do |am|
    am.errors[:money] << "price和total_fee不能同时出现" if am.repeat_money?
    am.errors[:money] << "price and total_fee can not both be blank" if am.money_blank?
    am.errors[:quantity] << "if price is not blank, must input quantity" if am.price_missing_quantity?
    am.errors[:seller] << "seller_email and seller_id can not both be blank" if am.seller_blank?
    am.errors[:sign] << "invalid sign" if am.invalid_sign?
    am.errors[:partner] << "not exist" if am.missing_partner?
  end

  def initialize(attributes = {})
    @attributes = attributes
    attributes.each do |name, value|
      send("#{name}=", value) if respond_to? name
    end
  end

  def repeat_money?
    self.price.to_s.length > 0 and self.total_fee.to_s.length > 0
  end

  def price_missing_quantity?
    self.price.to_s.length > 0 and self.quantity.to_s.length == 0
  end

  def missing_partner?
    return if self.partner.to_s.length == 0
    self.account == [] ? true : false
  end

  def seller_blank?
    self.seller_id.to_s.length == 0 and self.seller_email.to_s.length == 0
  end

  def money_blank?
    self.price.to_s.length == 0 and self.total_fee.to_s.length == 0
  end

  def invalid_sign?
    attrs = @attributes.dup
    attrs.delete("sign")
    attrs.delete("sign_type")
    text = attrs.delete_if{ |k, v| v.to_s.length == 0 }.sort.collect{ |s| s[0] + "=" + URI.decode(s[1]) }.join("&") + self.key
    self.sign == Digest::MD5.hexdigest(text) ? false : true
  end

  def account
    @account ||= self.class.accounts.assoc self.partner
    @account ||= []
  end

  def key
    self.account[1].to_s
  end

  def self.accounts
    @accounts ||= YAML.load_file('test/partner.yml')['alipay'] if ENV['magpie'] == 'test'
    @accounts ||= Magpie.yml_db['alipay']
  end


  def notify
    @notify ||= notify_attrs.inject({ }){ |notify, attr|
      notify[attr] = self.send(attr)
      notify
    }.merge("sign_type" => sign_type, "sign" => notify_sign)
  end

  def send_notify
    url = URI.parse notify_url
    res = Net::HTTP.post_form url, self.notify
    res.body
  end

  private
  def notify_id
    @notify_id ||= Time.now.to_i
  end

  def notify_time
    @notify_time ||= Time.now.strftime("%Y-%m-%d %H:%M:%S")
  end

  def notify_sign
    @notify_sign ||= Digest::MD5.hexdigest notify_text
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


end
