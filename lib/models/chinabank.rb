# -*- coding: utf-8 -*-

class ChinabankModel
  include ActiveModel::Validations

  # 商户编号
  attr_accessor :v_mid

  # 订单编号
  attr_accessor :v_oid

  # 订单总金额
  attr_accessor :v_amount

  # 币种
  attr_accessor :v_moneytype

  # 消费者完成购物后返回的商户页面，URL参数是以http://开头的完整URL地址
  attr_accessor :v_url

  # MD5校验码
  attr_accessor :v_md5info

  # 备注
  attr_accessor :remark1, :remark2


  validates_presence_of :v_mid, :v_oid, :v_amount, :v_moneytype, :v_url, :v_md5info
  validates_length_of :v_oid, :maximum => 64
  validates_length_of :v_url, :maximum => 200
  validates_format_of :v_amount, :with => /^[0-9]{1,6}\.[0-9]{1,2}$/, :message => "format should be Number(6, 2)", :allow_blank => true

  validate do |am|
    am.errors[:sign] << "invalid v_md5info" if am.invalid_sign?
  end

  def initialize(attributes = {})
    @attributes = attributes
    attributes.each do |name, value|
      send("#{name}=", value) if respond_to? name
    end
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

  def send_notify
    url = URI.parse notify_url
    res = Net::HTTP.post_form url, self.notify
    res.body
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
    %w{ 工商银行 招商银行 建设银行 光大银行 交通银行}[rand(5)]
  end

  def notify_text
    @notify_text ||= v_oid + v_pstatus + v_amount + v_moneytype + key
    rescue => e
    "invalid sign"
  end



end
