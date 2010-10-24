# -*- coding: utf-8 -*-
require 'net/https'
require 'uri'

module Magpie
  module Utils

    def dig(env)
      status, header, body = @app.call env
      req = Rack::Request.new env
      doc = send_req_to @pay_gateway, req
      red_text = Iconv.iconv("UTF-8//IGNORE","GBK//IGNORE", (doc/@red_xpath).inner_text).to_s
      return status, header, body, req, red_text
    end

    def send_req_to(gw, req)
      text = case req.request_method
             when "GET"; get_query(gw, req.query_string)
             when "POST"; post_query(gw, req.params)
             end
      doc = Hpricot text
    end

    def build_xml(h = { })
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
        "<result>" +
        hash_to_xml(h) +
        "</result>"
    end

    def hash_to_xml(h = { })
      h.inject(""){ |xml, (k, v)|
        case v
        when Hash, String
          xml << "<#{k}>"
          xml << (Hash === v ? hash_to_xml(v) : v)
          xml << "</#{k}>"
        when Array
          v.each{ |vv| xml << hash_to_xml(k => vv)}
          xml
        end

      }
    end

    def get_xml_body(env, am, red_text)
      if red_text.blank?
        begin_at = Time.now
        notify_res = send_notify(am.notify_url, am.notify).gsub(/<[^>]*>|<\/[^>]*>/m, '')
        now = Time.now
        env["magpie.notify"] = ["POST", am.notify_url, now.strftime("%d/%b/%Y %H:%M:%S"), now - begin_at, am.notify.inspect, notify_res ]
        xml_body = build_xml(:payment_success => "Yes",  :business => notify_res )
      else
        am.valid?
        xml_body = build_xml(:payment_success => "No", :errors => am.errors.merge(:final => red_text))
        env["magpie.errors.info"] = am.errors.merge(:final => red_text)
      end
      xml_body
    end

    def start_http(url, req)
      http = Net::HTTP.new(url.host, url.port)
      if url.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      http.start{ |hp| hp.request req }
    end

    def get_query(url, q_string)
      url = URI.parse(url + "?" + q_string)
      req = Net::HTTP::Get.new("#{url.path}?#{url.query}")
      res = start_http(url, req)
      res.body
    end

    def post_query(url, params)
      url = URI.parse url
      req = Net::HTTP::Post.new(url.path)
      req.set_form_data params
      res = start_http(url, req)
      res.body
    end

    # 向商户系统发送通知
    # @param [String, Hash] url是商户系统用来接收通知的url, notify是支付平台发过来的参数
    # @return [String] 如果有异常需要你确认url是否有效
    def send_notify(url, notify)
      url = URI.parse url
      timeout(8) do
        res = Net::HTTP.post_form url, notify
        case res
        when Net::HTTPSuccess, Net::HTTPRedirection; res.body
        else
          raise "#{res.class}@#{res.code}"
        end
      end
    rescue Exception => e
      "发送通知时出现异常#{e}, 请确认#{url}在你的商户系统中可用"
    end

  end
end
