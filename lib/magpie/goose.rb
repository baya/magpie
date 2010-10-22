# -*- coding: utf-8 -*-
module Magpie
  module Goose
    def self.included(m)
       m.extend ClassMethods
    end

    module ClassMethods

      # 用户定义验证规则
      #   validate :be_number, :not_blank
      #   validate do |item|
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
