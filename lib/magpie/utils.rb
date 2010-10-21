# -*- coding: utf-8 -*-
require 'net/https'
require 'uri'

module Magpie
  module Utils

    private
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
        xml << "<#{k}>"
        Hash === v ? xml << hash_to_xml(v) : xml << v.to_s
        xml << "</#{k}>"
      }
    end

    def get_xml_body(env, am, red_text)
      if red_text =~ /错误|\d+/
        final_error = get_final_error red_text
        am.valid?
        xml_body = build_xml(:payment_success => "F", :errors => am.errors.merge(:final => final_error))
        env["magpie.errors.info"] = am.errors.merge(:final => final_error)
      else
        begin_at = Time.now
        notify_res = send_notify(am.notify_url, am.notify).gsub(/<[^>]*>|<\/[^>]*>/m, '')
        now = Time.now
        env["magpie.notify"] = ["POST", am.notify_url, now.strftime("%d/%b/%Y %H:%M:%S"), now - begin_at, am.notify.inspect, notify_res ]
        xml_body = build_xml(:payment_success => "T",  :business => notify_res )
      end
      xml_body
    end

    # 在具体的中间件中重写
    def get_final_error(red_text)
      ""
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
    # @param[String, Hash] url是商户系统用来接收通知的url, notify是支付平台发过来的参数
    # @return[String] 如果有异常需要你确认url是否有效
    def send_notify(url, notify)
      url = URI.parse url
      timeout(8) do
        res = Net::HTTP.post_form url, notify
        res.body
      end
    rescue Exception => e
      "发送通知时出现异常#{e}, 请确认#{url}在你的商户系统中可用"
    end

  end
end
