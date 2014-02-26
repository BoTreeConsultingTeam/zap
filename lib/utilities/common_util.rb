module Utilities
  class CommonUtil

    private
    #### print methods
    def debug(msg)
      Rails.logger.debug msg
      puts "DEBUG :: #{msg}" if Rails.env.development?
    end

    def info(msg)
      Rails.logger.info msg
      puts "INFO :: #{msg}" if Rails.env.development?
    end

    def error(msg)
      Rails.logger.error "ERROR :: #{msg}"
      puts "ERROR :: #{msg}" if Rails.env.development?
    end
    
  end
end