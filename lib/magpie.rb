# -*- coding: utf-8 -*-
require 'open-uri'
require 'hpricot'
require 'iconv'
require 'rack'
require 'active_model'


module Magpie
  VERSION = [0, 8, 6, 2]

  class << self
    attr_accessor :yml_db

    def version
      VERSION.join(".")
    end
  end

  autoload :Utils,     "magpie/utils"
  autoload :Mothlog,   "middles/mothlog"
  autoload :Alipay,    "middles/alipay"
  autoload :Chinabank, "middles/chinabank"
  autoload :Server,    "magpie/server"


  APP = Rack::Builder.new {
    use Mothlog

    map "/alipay" do
      use Alipay
      run lambda{ |env| [200, {"Content-Type" => "text/xml"}, [""]]}
    end

    map "/chinabank" do
      use Chinabank
      run lambda { |env| [200, { "Content-Type" => "text/xml"}, [""]]}
    end

    map "/" do
      run lambda{ |env| [200, {"Content-Type" => "text/html"}, ["magpie"]]}
    end

  }.to_app


end



