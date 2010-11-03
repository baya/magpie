# -*- coding: utf-8 -*-
require 'open-uri'
require 'hpricot'
require 'iconv'
require 'net/https'
require 'uri'

module Magpie
  module Utils

    def dig(env)
      status, header, body = @app.call env
      req = Rack::Request.new env
      doc = send_req_to @pay_gateway, req
      red_text = (doc/@red_xpath).inner_text
      red_text = (doc/@error_xpath).inner_text if red_text.blank? and @error_xpath
      red_text = Iconv.iconv("UTF-8//IGNORE","GBK//IGNORE", red_text).to_s
      return status, header, body, req, red_text
    end

    def send_req_to(gw, req)
      text = case req.request_method
             when "GET"; get_query(gw, req.query_string).body
             when "POST"; post_query(gw, req.params).body
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
        notify_res = get_notify_res(am)
        xml_body = build_xml(:payment_success => "Yes",  :business => notify_res )
      else
        am.valid?
        xml_body = build_xml(:payment_success => "No", :errors => am.errors.merge(:final => red_text))
        log_errors(am.errors.merge(:final => red_text))
      end
      xml_body
    end

    def get_notify_res(am)
      case am
      when AlipayModel, ChinabankModel
        notify_res = send_notify("POST", am.notify_url, am.notify).gsub(/<[^>]*>|<\/[^>]*> |\s/m, '')
        method = "POST"
      when TenpayModel
        notify_res = send_notify("GET", am.notify_url, am.notify_string).gsub(/<[^>]*>|<\/[^>]*>|\s/m, '')
        method = "GET"
      end
      log_notify(method, am.notify_url, am.notify, notify_res)
      notify_res
    end

    def log_notify(method, notify_url, notify_params, notify_res)
      Magpie.logger.info(FORMAT_NOTIFY % [method, notify_url, Time.now.strftime("%d/%b/%Y %H:%M:%S"), notify_params.inspect, notify_res])
    end

    def log_errors(errors = { })
      Magpie.logger.info(errors.map{ |kv| "%s: %s" % kv }.join("\n"))
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
    end

    def post_query(url, params)
      url = URI.parse url
      req = Net::HTTP::Post.new(url.path)
      req.set_form_data params
      res = start_http(url, req)
    end

    # 向商户系统发送通知
    # @param [String, String, Hash] url是商户系统用来接收通知的url, notify是支付平台发过来的参数
    # @return [String] 如果有异常需要你确认url是否有效
    def send_notify(method, url, notify)
      times = [4, 6, 2]
      Rubber.try(3){|i|
        timeout(times[3-i]) do
          res = case method.to_s.upcase
                when "GET"; get_query(url, notify)
                when "POST"; post_query(url, notify)
                end
          case res
          when Net::HTTPSuccess, Net::HTTPRedirection; res.body
          else
            raise "#{res.class}@#{res.code}"
          end
        end
      }
    rescue Exception => e
      "发送通知时出现异常#{e}, 请确认#{url}在你的商户系统中可用, 比如#{url}是否可以#{method.upcase}方式接收其他应用的请求"
    end

  end
end
