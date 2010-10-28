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
      get_states = contents[:states].inject({ }){ |h, state|
        url_path = "/#{target}/#{state}"
        h[url_path] = self.class.reg(self, target, state)
        h["/#{target}"] = self.class.reg(self, target, state) if state.to_s == "index"
        h
      }

      post_actions = contents[:actions].inject({ }){ |h, action|
        url_path = "/#{target}/#{action}"
        h[url_path]= self.class.reg(self, target, action)
        h
      }

      @urls = { "GET" => get_states, "POST" => post_actions}


    end

    private

    def alipay_index
      @am = AlipayModel.new(@req.params)
      if @am.valid?
        render "alipay_success"
      else
        render "alipay_fail"
      end
    end

    def alipay_pay
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


  end

end
