# -*- coding: utf-8 -*-
require 'open-uri'
require 'hpricot'
require 'iconv'
require 'rack'

Object.class_eval{def blank?; self.to_s.gsub(/\s/, '').length == 0; end;}

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
  autoload :Snake,     "middles/snake"
  autoload :Alipay,    "middles/alipay"
  autoload :Chinabank, "middles/chinabank"
  autoload :Tenpay,    "middles/tenpay"
  autoload :Server,    "magpie/server"
  autoload :Goose,     "magpie/goose"
  autoload :Mouse,     "magpie/mouse"
  autoload :Dung,      "models/dung"



  BIRD_APP = Rack::Builder.new {
    use Mothlog

    map "/alipay" do
      use Alipay
      run lambda{ |env| [200, {"Content-Type" => "text/xml"}, [""]]}
    end

    map "/chinabank" do
      use Chinabank
      run lambda { |env| [200, { "Content-Type" => "text/xml"}, [""]]}
    end

    map "/tenpay" do
      use Tenpay
      run lambda { |env| [200, { "Content-Type" => "text/xml"}, [""]]}
    end

    map "/" do
      run lambda{ |env| [200, {"Content-Type" => "text/html"}, ["magpie"]]}
    end

  }

  SNAKE_APP = Rack::Builder.new {

    use Rack::ContentType, "text/html"
    use Rack::ContentLength
    use Rack::Static, :urls => ["/images"], :root => File.join(Dir.pwd, "..", "static")

    use Snake do |snake|
      snake.tongue :alipay,    :states => :index
      snake.tongue :chinabank, :states => :index, :actions => :index
      snake.tongue :tenpay,    :states => :index, :actions => :index
      snake.tongue :order,     :actions => :pay
    end

    run lambda { |env| [200, { }, [""]]}
  }


end



