# frozen_string_literal: true

require 'logging'

class CfnNagLogging
  def self.configure_logging(opts)
    logger = Logging.logger['log']
    logger.level = opts[:debug] ? :debug : :info
    logger.add_appenders Logging.appenders.stdout
  end
end
