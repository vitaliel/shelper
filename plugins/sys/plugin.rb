
module SHelper
  class Plugin < SHelper::BasePlugin
    version "1.0"
    name "plugin"
    author "Vitalie Lazu"
    description "System plugin that manipulates other plugins"

    def help
      show_help(nil)
    end

    def init
      {
        /^(:|-)help$/i => :show_help,
        /^help$/i => :show_help,
        /^:help ([a-z\-_0-9]+)$/ => :show_help_for,
        /^:plugin-list/i => :list_plugins,
      }
    end

    def show_help(msg)
      rez = ":help - shows this help\n"
      rez << ":help plugin_name - shows help for plugin_name\n"
      rez << ":plugin-list - shows installed plugins\n"

      @agent.send_message(configatron.admin.jid, rez)
    end

    def show_help_for(msg)
      @agent.show_help_for(msg[1])
    end

    def list_plugins(msg)
      @agent.list_plugins
    end
  end
end

SHelper.register_plugin SHelper::Plugin
