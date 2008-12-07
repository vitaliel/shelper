#
# Author: Vitalie Lazu <vitalie.lazu@gmail.com>
# Date: Sun, 23 Nov 2008 00:22:04 +0200
#

# DRB connector for xmpp agent

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

    class Task
      def initialize(agent, to, message)
        @agent = agent
        @to = to
        @message = message
        @task_id = "task-#{Time.now.to_i}-#{rand(1000)}"
        @text = []
        @msg_count = 1
        @received_msg = 0
        @mx = Mutex.new
        @msg_th = nil
      end

      def run
        begin
          thread = Thread.current

          @agent.send_command(@task_id, @to, @message) do |response|
            @msg_th = Thread.current unless @msg_th # ugly hack

            if response.subject =~ /(\d+):(\d+)/
              # check if we need to wait for other messages
              @mx.synchronize { @msg_count = $1.to_i }
            end

            @mx.synchronize { @received_msg += 1 }

            @text << response.body

            #puts "#{@msg_count.inspect} #{@received_msg.inspect}"

            if finish?
              thread.wakeup
              Thread.pass
            end
          end

          j = 1

          # Wait max 2 minutes for response
          while wait?
            j += 1
            # puts "shit!"

            sleep 1
            # ugly hack, bad ruby threads scheduler
            @msg_th.run if @msg_th

            break if j > 120
          end

          @text
        ensure
          @agent.remove_task(@task_id)
        end
      end

      def finish?
        @mx.synchronize {
          return @msg_count == @received_msg
        }
      end

      def wait?
        @mx.synchronize {
          return @msg_count != @received_msg
        }
      end
    end

    # Return an array with responses
    def send_message(secret_key, to, message)
      if secret_key != configatron.drb.secret_key
        # TODO log attempt
        return
      end

      Task.new(@agent, to, message).run
    end
  end
end
