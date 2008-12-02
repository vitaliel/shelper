module Os
  class Hostname < SHelper::BasePlugin
    name "hostname"
    description "This plugin will set server hostname"
    version "1.0"
    author "Vitalie Lazu"

    # Help that will be shown in case admin will send message with body ":help queue-daemon"
    def help
      rez = ":host - will return current hostname\n"
      rez << ":host DNS - will set new hostname\n"
    end

    # hash with regexp and method to call if regexp is matched
    cmd_map \
    /^:host/ => :cmd_show,
    /^:host\s+(#{CmdRegexp::DNS})/ => :cmd_set

    def cmd_show(msg)
      run_cmd "/bin/hostname"
    end

    # Parameters: dns
    def cmd_set(msg)
      File.open("/etc/hostname", "w") do |f|
        f.write "#{msg[1]}\n"
      end

      run_cmd "/bin/hostname #{msg[1]}"
    end
  end
end

# Register our plugin in the framework
SHelper.register_plugin Os::Hostname
