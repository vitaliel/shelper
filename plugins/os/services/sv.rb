
module Os;
  module Services;end
end

class Os::Services::Sv < SHelper::BasePlugin
  name "sv"
  description "plugin for runit sv command"
  author "Vitalie Lazu"

  cmd_map /^:sv\s+([a-z\-]+)\s+([a-zA-Z\-0-9]+)/ => :run_sv

  CMDS = %w{stop start status up down force-stop restart}

  def help
    ":sv #{CMDS.join '|'} SERVICE_NAME - will run sv command with argument"
  end

  # +msg+ regexp match $~
  def run_sv(msg)
    if CMDS.include?(msg[1])
      run_cmd("sv #{msg[1]} #{msg[2]}")
    else
      send_response "Error: unknown command argument #{msg[1]}"
    end
  end
end

SHelper.register_plugin Os::Services::Sv
