require 'shelper/file_util'

module SHelper;end

class SHelper::BasePlugin
  include Annotatable

  annotate :version, :name, :url, :description, :author

  # *hash* key: cmd_regexp, :value => :cmd_to_execute
  # Example:
  # cmd_map /^help$/ => :show_help
  annotate :cmd_map

  attr_writer :agent, :sender, :message

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
    send_response("Command '#{cmd}' exited with status: #{rez[1]}") if rez[1] != 0
    return rez[1]
  rescue => e
    send_response("Error: #{e.class} #{e.message}\n#{e.backtrace.join "\n"}")
  end

  def send_response(msg)
    answer = @message.answer(true)
    answer.id = "r" << answer.id if answer.id
    # pidgin sends html version also
    answer.delete_element "html"
    answer.body = msg
    @agent.send_raw(answer)
  end

  def file_util(file_path)
    fu = SHelper::FileUtil.new(file_path)
    # fu.backup_store = BackupStore.new
    fu
  end
end
