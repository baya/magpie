# -*- coding: utf-8 -*-
require 'models/alipay'

module Magpie

  class Alipay
    include Utils

    def initialize(app, pay_gateway = "https://www.alipay.com/cooperate/gateway.do")
      @app = app
      @pay_gateway = pay_gateway
    end

    def call(env)
      status, header, body = @app.call(env)
      req = Rack::Request.new(env)
      doc = send_req_to @pay_gateway, req
      red_text = (doc/"//div[@id='Info']/div[@class='ErrorInfo']/div[@class='Todo']").inner_text
      red_text = Iconv.iconv("UTF-8//IGNORE","GBK//IGNORE", red_text).to_s
      am = AlipayModel.new(req.params)
      [status, header, get_xml_body(env, am, red_text)]
    end

    private

    def get_final_error(red_text)
      red_text
    end

  end
end
