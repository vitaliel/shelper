require 'rubygems'
require 'configatron'

require 'xmpp4r'
require 'xmpp4r/roster/helper/roster'

require 'shelper/command'
require 'shelper/agent'

module SHelper
  class << self
    # pass config file
    def start(argv = ARGV)
      if argv.size > 0
        configatron.configure_from_yaml(argv[0]) if test ?f, argv[0]
      else
        raise "Provide config file"
      end

      bot = Agent.new

      begin
        bot.connect
        bot.send_message("vitaliel@localhost", "Bot reporting for duty at #{Time.now}", false)
        bot.start_worker_thread
      rescue Interrupt => ignore
      ensure
        bot.disconnect
      end
    end
  end
end
