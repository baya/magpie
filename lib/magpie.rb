# -*- coding: utf-8 -*-
require 'rack'
require 'logger'

Object.class_eval{def blank?; respond_to?(:empty?) ? empty? : !self end;}

module Magpie

  VERSION = [0, 8, 8, 2]
  FORMAT_ERRORS = %{%s : "%s" \n}
  FORMAT_NOTIFY =  %{Notify to [%s] %s at[%s]\n Parameters:%s\n\nBusiness result:%s\n\n}

  class << self
    attr_accessor :yml_db
    attr_accessor :logger

    def version
      VERSION.join(".")
    end
  end

  Magpie.logger = Logger.new("test/test.log") if ENV["magpie"] == 'test'

  autoload :Utils,          "magpie/utils"
  autoload :Rubber,         "magpie/rubber"
  autoload :Mothlog,        "middles/mothlog"
  autoload :Snake,          "middles/snake"
  autoload :Server,         "magpie/server"
  autoload :Goose,          "magpie/goose"
  autoload :Mouse,          "magpie/mouse"
  autoload :Dung,           "models/dung"
  autoload :AlipayModel,    "models/alipay"
  autoload :TenpayModel,    "models/tenpay"
  autoload :ChinabankModel, "models/chinabank"

end



