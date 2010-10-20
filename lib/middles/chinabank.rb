# -*- coding: utf-8 -*-
require 'models/chinabank'

module Magpie

  class Chinabank
    include Utils

    def initialize(app, pay_gateway = "https://pay3.chinabank.com.cn/PayGate")
      @app = app
      @pay_gateway = pay_gateway
    end

    def call(env)
      status, header, body = @app.call(env)
      req = Rack::Request.new(env)
      doc = send_req_to @pay_gateway, req
      red_text = Iconv.iconv("UTF-8//IGNORE","GBK//IGNORE", (doc/"//strong[@class='red']").inner_text).to_s
      am = ChinabankModel.new(req.params)
      [status, header, get_xml_body(env, am, red_text)]
    end

    private

    def get_final_error(red_text)
      red_text.match(/出错了!(.*)/)[1]
    end


  end
end
