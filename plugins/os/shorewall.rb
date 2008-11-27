
module Os
  class Shorewall < SHelper::BasePlugin
    name "shorewall"
    description "plugin to talk to shorewall firewall"
    author "Vitalie Lazu"
    version "1.0"

    cmd_map \
    /^:sw\s+(status|st|save|list|restart)/i => :sw_cmd,
    /^:sw\s+allow\s+(tcp|udp)\s+(#{CmdRegexp::IP_MASK})\s*(\d+)?/i => :add_to_rules,
    /^:sw\s+(remove|del)\s+(#{CmdRegexp::IP_MASK})/i => :del_from_rules,
    /^:sw\s+(allow|drop|reject)\s+(#{CmdRegexp::IP_MASK})/i => :allow_reject

    def help
      rez = ""
      rez << ":sw status - will show the status of firewall\n"
      rez << ":sw save|list - will save/list firewall dynamic rules\n"
      rez << ":sw restart - will restart firewall\n"
      rez << ":sw allow tcp|udp SRC_IP [PORT] - will modify $SHOREWALL_CONF_DIR/rules file and will add rule\n"
      rez << ":sw remove|del SRC_IP - will modify $SHOREWALL_CONF_DIR/rules file and will remove all lines mathing SRC_IP\n"
      rez << ":sw allow|drop|reject IP_MASK - will allow/drop/reject connections from IP_ADDRESS, dynamic rules\n"
    end

    # Parameters: cmd, src ip
    def del_from_rules(msg)
      if file_util(rules_file).remove_line(msg[2])
        reply = "Removed lines from #{rules_file} mathing #{msg[2].inspect}."
      else
        reply = "Lines mathing #{msg[2].inspect} were not found."
      end

      send_response(reply)
    end

    # Paramerters: protocol, src ip, [port]
    def add_to_rules(msg)
      # TODO use configatron config parameter for conf dir
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

      if i >= 0
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
      cmd = msg[1]
      cmd = "status" if cmd =~ /^st/
      cmd = "list" if cmd =~ /^show/

      run_cmd("shorewall " << cmd)
    end

    def allow_reject(msg)
      if run_cmd("shorewall #{msg[1].downcase} #{msg[2]}") == 0
        system("shorewall save")
      end
    end

    def rules_file
      "/etc/shorewall/rules"
    end
  end
end

SHelper.register_plugin Os::Shorewall
