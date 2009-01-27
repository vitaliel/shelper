#
# Author: Vitalie Lazu <vitalie.lazu@gmail.com>
# Date: Thu, 27 Nov 2008 16:36:34 +0200
#

require 'configatron'

begin
  require 'xmpp4r'
rescue LoadError
  require 'rubygems'
  require 'xmpp4r'
end

require 'xmpp4r/roster/helper/roster'
require 'xmpp4r/version/iq/version'

require 'net/http'
require 'uri'

require 'utils/annotatable'

require 'shelper/base_plugin'
require 'shelper/command'
require 'shelper/agent'

Thread.abort_on_exception = true

module SHelper
  class << self
    # pass config file
    def start(argv = ARGV)
      if argv.size > 0
        configatron.configure_from_yaml(argv[0]) if test ?f, argv[0]
      else
        raise "Provide config file!"
      end

      configatron.log_dir = File.dirname(__FILE__) + "/../log/" if configatron.log_dir.nil?
      logger.info("SHelper start")

      unless configatron.xmpp.debug.nil?
        Jabber.logger = Logger.new "#{configatron.log_dir}/jabber.log"
        Jabber.debug = true
      end

      unless configatron.ec2.nil?
        configatron.xmpp.resource = fetch_instance_id
      end

      @agent = Agent.new
      @agent.logger = logger

      if configatron.drb.enabled == true
        logger.info "Loading Drb connector"
        require 'shelper/drb'

        SHelper::Drb.new(@agent)
      end

      load_plugins

      begin
        @agent.connect
        @agent.send_message(configatron.admin.jid, "Agent at #{`hostname`.strip} is ready to serve.")
        @agent.start_worker
      rescue Interrupt => ignore
      ensure
        @agent.disconnect
      end
    end

    def load_plugins
      # load system plugins
      load_plugins_from File.dirname(__FILE__) + "/../plugins/"

      # load other plugins
      plugins_dir = configatron.plugins_dir

      unless plugins_dir.nil?
        if test(?d, plugins_dir)
          load_plugins_from plugins_dir
        else
          logger.error "Plugin dir does not exists: #{plugins_dir}"
        end
      end
    end

    def load_plugins_from(dir)
      Dir["#{File.expand_path dir}/**/*.rb"].each do |f|
        logger.debug "Loading plugin: #{f}"
        require f
      end
    end

    def register_plugin(klass)
      @agent.add_plugin(klass)

      # check for cron jobs
      if klass.cron_jobs
        for cron_line, method in klass.cron_jobs
          logger.info("Cron: registering #{klass}##{method} to run at #{cron_line}")
          scheduler.schedule(cron_line) do
            logger.info("Cron: starting #{klass}##{method}...")
            obj = klass.new
            obj.agent = @agent
            obj.send(method)
          end
        end
      end
    end

    def scheduler
      require 'rufus/scheduler'
      @scheduler ||= Rufus::Scheduler.start_new
    end

    def fetch_instance_id
      url = URI.parse('http://169.254.169.254/latest/meta-data/instance-id')

      res = Net::HTTP.start(url.host, url.port) do |http|
        http.get(url.path)
      end

      res.body.strip
    end

    def logger
      @@logger ||= Logger.new "#{configatron.log_dir}/shelper.log"
    end
  end
end
