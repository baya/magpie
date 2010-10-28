
require 'models/tenpay'

module Magpie

  class Tenpay
    include Utils

    def initialize(app, pay_gateway = "http://service.tenpay.com/cgi-bin/v3.0/payservice.cgi")
      @app = app
      @pay_gateway = pay_gateway
      @red_xpath = "//div[@id='error-info']"
      @error_xpath = "//td[@class='font_14']"
    end

    def call(env)
      status, header, body, req, red_text = dig env
      [status, header, get_xml_body(env, TenpayModel.new(req.params), red_text)]
    end

  end
end
