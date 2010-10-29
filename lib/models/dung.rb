# -*- coding: utf-8 -*-
module Magpie
  class Dung

    def initialize(am)
      @am = am
    end

    def total_fee
      @total_fee ||= case @am
                     when AlipayModel;    @am.total_fee
                     when TenpayModel;    @am.total_fee.to_f/100
                     when ChinabankModel; @am.v_amount
                     end
    end

    def subject
      @subjedt ||= case @am
                   when AlipayModel;    @am.subject
                   when TenpayModel;    @am.desc
                   when ChinabankModel; nil
                   end
    end

    def merchant
      @merchant ||= "北京锋讯在线信息技术有限公司"
    end

    def trade_kind
      @trade_kind ||= "即时到帐交易"
    end

    def trade_no
      @trade_no ||= case @am
                    when AlipayModel;    @am.out_trade_no
                    when TenpayModel;    @am.transaction_id
                    when ChinabankModel; @am.v_oid
                    end
    end

    def price
      @price ||= case @am
                 when AlipayModel; @am.price || @am.total_fee
                 when TenpayModel; @am.total_fee.to_f/100
                 when ChinabankModel; @am.v_amount
                 end
    end

    def notify_url
      @notify_url ||= @am.notify_url
    end

    def notify_to_query
      @nq ||= @am.notify.map{ |kv| "%s=%s" % kv }.join("&")
    end

    def name
      @name ||= case @am
                when AlipayModel; "alipay"
                when TenpayModel; "tenpay"
                when ChinabankModel; "chinabank"
                end
    end

  end
end
