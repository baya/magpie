# -*- coding: utf-8 -*-
module Magpie
  module Goose

    def initialize(attributes = {})
      @attributes = attributes
      attributes.each do |name, value|
        send("#{name}=", value) if respond_to? name
      end
    end

    def self.included(m)
      m.extend ClassMethods
    end

    module ClassMethods

      # 用户定义验证规则
      #   goose_validate :be_number, :not_blank
      #   goose_validate do |item|
      #     item.errors[:name] << "名字的长度不能超过4" if item.name.length > 4
      #   end
      # param [Array, Proc], 将验证规则添加到@validations中
      def goose_validate(*ms, &p)
        @validations ||= []
        unless ms.to_s.length == 0
          ms.each { |m| @validations << m.to_s unless @validations.member?(m.to_s)}
        end
        @validations << p unless p.to_s.length == 0
      end

      def validations
        (@validations ||=[]).dup
      end

      def goose_validate_presence_of(*attrs)
        attrs.each { |attr|
          goose_validate do |am|
            am.errors[attr] << "can't be blank" if am.send(attr).blank?
          end
        }
      end

      def goose_validate_format_of(*attrs)
        attrs, options = parse_options(attrs)
        attrs.each do |attr|
          goose_validate { |am|
            am.errors[attr] << (options[:msg] || "格式错误") unless am.send(attr) =~ options[:with] or (options[:allow_blank] and  am.send(attr).blank?)
          }
        end

      end

      def goose_validate_length_of(*attrs)
        attrs, options = parse_options attrs
        min_length = options[:min_length] || 0
        max_length = options[:max_length]
        attrs.each do |attr|
          goose_validate { |am|
            attr_length = am.send(attr).to_s.length
            am.errors[attr] << (options[:msg] || "长度错误") unless max_length.blank? or (attr_length >= min_length and attr_length <= max_length) or (options[:allow_blank] and am.send(attr).blank?)
          }
        end
      end

      def parse_options(attrs)
        options = attrs.select{ |attr| attr.is_a? Hash}
        return attrs - options, options.first
      end

    end

    def errors
      @errors ||= Hash.new{ |h, k| h[k.to_sym] = []}
    end

    def validating
      self.class.validations.each {|v| String === v ? self.send(v) : v.call(self) }
    end

    def valid?
      @validated ||= validating
      self.errors.values.flatten.empty?
    end

  end

end
