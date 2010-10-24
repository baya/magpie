# -*- coding: utf-8 -*-
require 'models/alipay'

module Magpie

  class Alipay
    include Utils

    def initialize(app, pay_gateway = "https://www.alipay.com/cooperate/gateway.do")
      @app = app
      @pay_gateway = pay_gateway
      @red_xpath = "//div[@id='Info']/div[@class='ErrorInfo']/div[@class='Todo']"
    end

    def call(env)
      status, header, body, req, red_text = dig env
      [status, header, get_xml_body(env, AlipayModel.new(req.params), red_text)]
    end

  end
end
