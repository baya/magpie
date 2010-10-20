
module Magpie
  class Mothlog

    FORMAT = %{%s : "%s" \n}
    FORMAT_NOTIFY =  %{\t[%s] %s at[%s] (%0.4fms)\nParameters:%s\nResult:%s\n}

    def initialize(app, logger=nil)
      @app = app
      @logger = logger
    end

    def call(env)
      status, header, body = @app.call(env)
      log(env)
      [status, header, body]
    end

    private
    def log(env)
      logger = @logger || env['rack.errors']
      errors_info = env["magpie.errors.info"] || { }
      logger.write("\n\n")
      unless errors_info.empty?
        logger.write("ErrorInfo:\n")
        errors_info.each { |k, v| logger.write FORMAT % [k, v]}
      end
      if errors_info.empty? and env["magpie.notify"]
        logger.write FORMAT_NOTIFY % env["magpie.notify"]
      end
    end
  end
end
