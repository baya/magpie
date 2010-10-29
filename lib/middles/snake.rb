# -*- coding: utf-8 -*-
require 'erb'

module Magpie

  class Snake
    include Utils

    def self.reg(snake, target, state)
      proc{ instance_method("#{target}_#{state}").bind(snake).call}
    end

    def initialize(app, &block)
      @app = app
      @block = block
    end

    def call(env)
      state, header, body = @app.call(env)
      @block.call(self)
      @req = Rack::Request.new(env)
      @urls[@req.request_method].each { |path, lamb|
        if @req.path_info =~ Regexp.new("^#{path}$")
          body = lamb.call
          break
        end
      }
      [state, header, body]
    end

    def tongue(target, contents = { })
      @urls ||= { "GET" => { }, "POST" => { }}
      get_states = contents[:states].inject({ }){ |h, state|
        url_path = "/#{target}/#{state}"
        h[url_path] = reg(target, state)
        h["/#{target}"] = reg(target, state) if state.to_s == "index"
        h
      }

      post_actions = contents[:actions].inject({ }){ |h, action|
        url_path = "/#{target}/#{action}"
        h[url_path] = reg(target, action)
        h["/#{target}"]= reg(target, action) if action.to_s == "index"
        h
      }

      @urls["GET"].merge!(get_states)
      @urls["POST"].merge!(post_actions)
    end

    def reg(target, state)
      self.class.reg(self, target, state)
    end

    private

    def alipay_index
      @am = AlipayModel.new(@req.params)
      if @am.valid?
        @dung = Dung.new(@am)
        render("success")
      else
        render("fail")
      end
    end

    def alipay_pay
      notify = query_to_hash(@req.params["notify"])
      body = send_notify(@req.params["notify_url"], notify)
    end

    def chinabank_index
      @am = ChinabankModel.new(@req.params)
      if @am.valid?
        @dung = Dung.new(@am)
        render("success")
      else
        render("fail")
      end
    end

    def chinabank_pay
      notify = query_to_hash(@req.params["notify"])
      body = send_notify(@req.params["notify_url"], notify)
    end

    def tenpay_index
      @am = TenpayModel.new(@req.params)
      if @am.valid?
        @dung = Dung.new(@am)
        render("success")
      else
        render("fail")
      end
    end

    def tenpay_pay
      notify = query_to_hash(@req.params["notify"])
      body = send_notify(@req.params["notify_url"], notify)
    end

    def render(file_name)
      file_path = File.join(File.dirname(__FILE__), "../..", "lib", "views", "#{file_name}.html.erb")
      template = ERB.new(File.read(file_path))
      template.result(binding)
    end

    def query_to_hash(query)
      hash_params = query.split("&").inject({ }){ |h, q| qs = q.split("="); h[qs[0]] = qs[1]; h }
    end

    def pay_url(name)
      "/#{name}/pay"
    end


  end

end
