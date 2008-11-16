
module Os
  class Shorewall < SHelper::BasePlugin
    name "shorewall"
    description "plugin to talk to shorewall firewall"
    author "Vitalie Lazu"
    version "1.0"

    cmd_map \
    /^:shorewall\s+status/i => :sw_status,
    /^:shorewall\s+save/i => :sw_save,
    /^:shorewall\s+list/i => :sw_list,
    /^:shorewall\s+(allow|drop|reject)\s+([0-9.\/]+)/i => :allow_reject

    def help
      rez = ""
      rez << ":shorewall status - will show the status of firewall\n"
      rez << ":shorewall save|list - will save/list firewall rules\n"
      rez << ":shorewall allow|drop|reject IP_ADDRESS - will allow/drop/reject connections from IP_ADDRESS\n"
    end

    def sw_status(msg)
      run_cmd("shorewall status")
    end

    # Saves shorewall rules
    def sw_save(msg)
      run_cmd("shorewall save")
    end

    # Lists shorewall rules
    def sw_list(msg)
      run_cmd("shorewall list")
    end

    def allow_reject(msg)
      if run_cmd("shorewall #{msg[1].downcase} #{msg[2]}") == 0
        system("shorewall save")
      end
    end
  end
end

SHelper.register_plugin Os::Shorewall
