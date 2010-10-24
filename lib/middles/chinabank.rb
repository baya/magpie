# -*- coding: utf-8 -*-
require 'models/chinabank'

module Magpie

  class Chinabank
    include Utils

    def initialize(app, pay_gateway = "https://pay3.chinabank.com.cn/PayGate")
      @app = app
      @pay_gateway = pay_gateway
      @red_xpath = "//strong[@class='red']"
    end

    def call(env)
      status, header, body, req, red_text = dig env
      [status, header, get_xml_body(env, ChinabankModel.new(req.params), red_text)]
    end

  end
end
