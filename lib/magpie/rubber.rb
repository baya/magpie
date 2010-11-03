module Magpie
  module Rubber

    def self.try(times = 1, options = { }, &block)
      val = yield times
    rescue options[:on] || Exception => e
      Magpie.logger.info("#{Time.now}:#{__FILE__}:#{__LINE__}}:#{e.backtrace[0..8].join("\n")}")
      retry if (times -= 1) > 0
      raise e
    else
      val
    end

  end

end
