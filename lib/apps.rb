

module Magpie

  BIRD_APP = Rack::Builder.new {

    use Rack::ContentType, "text/xml"
    use Rack::ContentLength

    map "/alipay" do
      use Alipay
      run lambda{ |env| [200, {}, [""]]}
    end

    map "/chinabank" do
      use Chinabank
      run lambda { |env| [200, {}, [""]]}
    end

    map "/tenpay" do
      use Tenpay
      run lambda { |env| [200, {}, [""]]}
    end

  }

  SNAKE_APP = Rack::Builder.new {

    use Rack::ContentType, "text/html"
    use Rack::ContentLength
    use Rack::Static, :urls => ["/images"], :root => File.join(File.dirname(__FILE__), "..", "static")

    use Snake do |snake|
      snake.tongue :alipay,    :states => :index
      snake.tongue :chinabank, :states => :index, :actions => :index
      snake.tongue :tenpay,    :states => :index, :actions => :index
      snake.tongue :order,     :actions => :pay
    end

    run lambda { |env| [200, { }, [""]]}
  }

end
