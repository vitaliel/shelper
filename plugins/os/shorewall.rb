
module Os
  class Shorewall < SHelper::BasePlugin
    name "shorewall"
    description "plugin to talk to shorewall firewall"
    author "Vitalie Lazu"
    version "1.0"

    cmd_map \
    /^:shorewall\s+(status|save|list|restart)/i => :sw_cmd,
    /^:shorewall\s+allow\s+(tcp|udp)\s+([0-9.\/]+)\s*(\d+)?/i => :add_to_rules,
    /^:shorewall\s+(allow|drop|reject)\s+([0-9.\/]+)/i => :allow_reject

    def help
      rez = ""
      rez << ":shorewall status - will show the status of firewall\n"
      rez << ":shorewall save|list - will save/list firewall rules\n"
      rez << ":shorewall restart - will restart firewall\n"
      rez << ":shorewall allow tcp|udp SRC_IP [PORT] - will modify $SHOREWALL_CONF_DIR/rules file and will add rule\n"
      rez << ":shorewall allow|drop|reject IP_ADDRESS - will allow/drop/reject connections from IP_ADDRESS\n"
    end

    # $1 - protocol, $2 src ip, $3 - optional port
    def add_to_rules(msg)
      # TODO use configatron config parameter for conf dir
      rules_file = "/etc/shorewall/rules"
      line = "ACCEPT net:#{msg[2]} fw #{msg[1]}"
      line << " " << msg[3] if msg[3]
      line << "\n"
      lines = []

      File.open(rules_file) do |f|
        lines = f.readlines
      end

      i = lines.size - 1

      while i >= 0 && lines[i] !~ /\s*#LAST LINE -- ADD YOUR ENTRIES/
        i -= 1
      end

      if i >=0
        a = [line, lines[i]]
        lines[i,i] = a

        # TODO ask agent to backup original file

        File.open(rules_file, "w") do |f|
          f.write lines.join
        end

        message = "#{rules_file} updated, run shorewall restart to reload the rules."
      else
        message = "Can not find last mark line"
      end

      send_response(message)
    end

    def sw_cmd(msg)
      run_cmd("shorewall #{msg[1]}")
    end

    def allow_reject(msg)
      if run_cmd("shorewall #{msg[1].downcase} #{msg[2]}") == 0
        system("shorewall save")
      end
    end
  end
end

SHelper.register_plugin Os::Shorewall
