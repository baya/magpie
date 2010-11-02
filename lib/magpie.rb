# -*- coding: utf-8 -*-
require 'rack'
require 'logger'

Object.class_eval{def blank?; self.to_s.gsub(/\s/, '').length == 0; end;}

module Magpie

  VERSION = [0, 8, 6, 2]
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

  autoload :Utils,     "magpie/utils"
  autoload :Mothlog,   "middles/mothlog"
  autoload :Snake,     "middles/snake"
  autoload :Alipay,    "middles/alipay"
  autoload :Chinabank, "middles/chinabank"
  autoload :Tenpay,    "middles/tenpay"
  autoload :Server,    "magpie/server"
  autoload :Goose,     "magpie/goose"
  autoload :Mouse,     "magpie/mouse"
  autoload :Dung,      "models/dung"

end



