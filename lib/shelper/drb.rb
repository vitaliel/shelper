# DRB connector for xmpp agent
# Created by Vitalie Lazu at Sun, 23 Nov 2008 00:22:30 +0200

require 'drb'
require 'drb/acl'

module SHelper
  class Drb
    attr_reader :agent

    def initialize(agent)
      @agent = agent

      acl_list = ["deny", "all"]

      configatron.drb.acl.scan(/\S+/).each do |hostname|
        acl_list += ["allow", hostname]
      end

      DRb.install_acl(ACL.new(acl_list))
      DRb.start_service("druby://#{configatron.drb.listen}", self)
    end

    def send_message(secret_key, to, message)
      if secret_key != configatron.drb.secret_key
        # TODO log attempt
        return
      end

      task_id = "task-#{Time.now.to_i}-#{rand(1000)}"
      text = nil
      thread = Thread.current

      begin
        @agent.send_command(task_id, to, message) do |response|
          text = response.body
          thread.wakeup
        end

        # Wait max a minute for response
        sleep 60

        text
      ensure
        @agent.remove_task(task_id)
      end
    end
  end
end
