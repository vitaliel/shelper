# Should have my_company/daemon.rb path

module MyCompany
  class Daemon < SHelper::BasePlugin
    name "queue-daemon"
    description "This plugin will save some of my time"
    version "1.0"
    author "Your Name"

    # Help that will be shown in case admin will send message with body ":help queue-daemon"
    def help
      rez = "qd: config parameter value - will set plugin configuration parameter, params: config_path"
      rez << "qd: add-ip 127.0.0.4 - will add IP to queue-daemon acl"
    end

    # hash with regexp and method to call if regexp is matched
    cmd_map \
    /^qd: config ([^\s]+)\s+(.*)/i => :cmd_config,
    /^qd: add-ip (.*)/i => :cmd_add_ip_to_acl

    # This method will be called for first command in command map
    # +msg+ - is a regexp matched data: you can access parameters with msg[1] for $1, msg[2] - $2 and so on
    def cmd_config(msg)
      # TODO
      send_response("Operation was completed successfully.")
    end

    # This method will be called for second command in command map
    # +msg+ - is a regexp matched data: you can access parameters with msg[1] for $1, msg[2] - $2 and so on
    def cmd_add_ip_to_acl(msg)
      # Reply will be sent to user that sent this message
      # output will be sent to user too
      # if command is not a task, command that was executed and return code will be sent too
      run_cmd "/bin/echo hi"
    end
  end
end

# Register our plugin in the framework
SHelper.register_plugin MyCompany::Daemon
