# Should have my_company/daemon.rb path

module Os
  class Mysql < SHelper::BasePlugin
    name "mysql"
    description "This plugin is a frontend for mysqladmin command"
    version "1.0"
    author "Vitalie Lazu"

    # Help that will be shown in case admin will send message with body ":help queue-daemon"
    def help
      rez = ":mysql processlist - will show process list\n"
      rez << ":mysql status - will show mysql status\n"
      rez << ":mysql kill ID1[ ID2 ID3 ...] - will kill threads\n"
    end

    # hash with regexp and method to call if regexp is matched
    cmd_map \
    /^:mysql\s+kill\s+([\s0-9]+)/i => :mysql_kill,
    /^:mysql\s+(processlist|status)/i => :mysql_cmd

    # Parameters: mysqladmin
    def mysql_cmd(msg)
      run_cmd "mysqladmin #{msg[1]}"
    end

    # Parameters: thread ids separated by space
    def mysql_kill(msg)
      ids = msg[1].split.join(",")
      run_cmd "mysqladmin kill #{ids}"
    end
  end
end

# Register our plugin in the framework
SHelper.register_plugin Os::Mysql
