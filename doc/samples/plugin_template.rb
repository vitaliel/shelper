
module MyModule
  class MyPlugin < SHelper::Plugin
    def help
      "cmd1: config parameter value - will set plugin configuration parameter, params: config_path"
      "cmd2: add-ip 127.0.0.4 - will add IP to daemon acl"
    end

    def init
      {/^cmd1: config ([^\s]+)\s+(.*)/i => :cmd1}
      {/^cmd2: add-ip (.*)/i => :cmd2}
    end

    # TODO: Implement me
    def cmd1(msg)
    end

    # TODO: Implement me
    def cmd2(msg)
    end
  end
end

SHelper.register_plugin MyModule::MyPlugin
