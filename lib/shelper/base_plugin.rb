
module SHelper;end

class SHelper::BasePlugin
  include Annotatable

  annotate :version, :name, :url, :description, :author

  # *hash* key: cmd_regexp, :value => :cmd_to_execute
  # Example:
  # cmd_map /^help$/ => :show_help
  annotate :cmd_map

  attr_writer :agent, :sender

  # Will be called to init the plugin
  def init
  end

  # Provide help how to use the plugin
  def help
  end

  def run_cmd(cmd)
    @cmd_ctl = SHelper::Command.new(cmd) do |output|
      send_response(output)
    end

    rez = @cmd_ctl.wait
    send_response("Command '#{cmd}' exited with status: #{rez[1]}")
  rescue => e
    send_response("Error: #{e.class} #{e.message}\n#{e.backtrace.join "\n"}")
  end

  def send_response(msg)
    @agent.send_message(@sender, msg)
  end
end
