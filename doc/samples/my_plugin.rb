module SA
  class Daemon < SHelper::Plugin
    def help
      "qd: config parameter value - will set plugin configuration parameter, params: config_path"
      "qd: add-ip 127.0.0.4 - will add IP to queue-daemon acl"
    end

    def init
      {/^qd: config ([^\s]+)\s+(.*)/i => :cmd_config}
      {/^qd: add-ip (.*)/i => :cmd_add_ip_to_acl}
    end

    def cmd_config(msg)
      # TODO save
    end

    def cmd_add_ip_to_acl(msg)

    end
  end
end

SHelper.register_plugin SA::Daemon
