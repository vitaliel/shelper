
module SHelper
  class Plugin < SHelper::BasePlugin
    version "1.0"
    name "plugin"
    author "Vitalie Lazu"
    description "System plugin that manipulates other plugins"

    cmd_map \
    /^(:|-)help$/i => :show_help,
    /^help$/i => :show_help,
    /^:help ([a-z\-_0-9]+)$/ => :show_help_for,
    /^:plugin(s)?-list/i => :list_plugins

    def help
      show_help(nil)
    end

    def show_help(msg)
      rez = "Available commands\n"
      rez << ":help - shows this help\n"
      rez << ":help plugin_name - shows help for plugin_name\n"
      rez << ":plugin-list - shows installed plugins\n"

      send_response(rez)
    end

    def show_help_for(msg)
      send_response @agent.show_help_for(msg[1])
    end

    def list_plugins(msg)
      send_response @agent.list_plugins
    end
  end
end

SHelper.register_plugin SHelper::Plugin
