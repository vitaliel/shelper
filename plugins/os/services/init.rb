
module Os;
  module Services;end
end

class Os::Services::Init < SHelper::BasePlugin
  name "service"
  description "plugin for init.d commands"
  author "Vitalie Lazu"

  cmd_map /^:service\s+([a-z\-]+)\s+([a-zA-Z\-0-9]+)/ => :run_service

  CMDS = %w{stop start reload restart}

  def help
    ":service #{CMDS.join '|'} SERVICE_NAME - will run sv command with argument"
  end

  # +msg+ regexp match $~
  def run_service(msg)
    if CMDS.include?(msg[1])
      # TODO work around FREEBSD: search service in /etc/rc.d/ then in /usr/local/etc/rc.d/
      run_cmd("/etc/init.d/#{msg[1]} #{msg[2]}")
    else
      send_response "Error: unknown command argument #{msg[1]}"
    end
  end
end

SHelper.register_plugin Os::Services::Init
