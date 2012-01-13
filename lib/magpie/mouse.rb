# -*- coding: utf-8 -*-

module Magpie

  #获取一些持久化信息,主要是商户账号
  module Mouse

    class MouseError < StandardError;end

    def self.included(m)
      m.extend ClassMethods
    end

    module ClassMethods

      def set_accounts_kind(kind, options={ })
        @kind = kind.to_s
        @accounts_env = options[:env] || "development"
      end

      def accounts
        @accounts ||= @accounts_env == 'test' ?  YAML.load_file('test/partner.yml')[@kind] : Magpie.yml_db[@kind]
        raise MouseError.new("#{@kind}商号配置出错,请检查#{@kind}的商号是否配置正确") if @accounts.nil?
        @accounts
      end

    end

    def account
      @account ||= self.class.accounts.assoc self.partner
      @account ||= []
    end

    def key
      @key ||= self.account[1].to_s
    end

    def missing_partner?
      self.account == []
    end

  end
end
