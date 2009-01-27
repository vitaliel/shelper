#
# Author: Vitalie Lazu <vitalie.lazu@gmail.com>
# Date: Thu, 27 Nov 2008 16:10:04 +0200
#

module SHelper;end

class SHelper::Agent
  include Jabber

  attr_accessor :logger

  def initialize
    if configatron.xmpp.resource.nil?
      configatron.xmpp.resource = "SHelperAgent"
    end

    user = JID.new("#{configatron.xmpp.username}/#{configatron.xmpp.resource}")

    @password = configatron.xmpp.password
    @client = Client.new(user)
    @cmd_map = {}
    @mutex = Mutex.new
    @task_map = {}
  end

  def connect
    try_to_connect

    @client.auth(@password)
    post_connect if @client
  end

  def try_to_connect
    loop do
      begin
        @client.connect(configatron.xmpp.server_name, configatron.xmpp.port)
        @connected = true
        break
      rescue Errno::ECONNREFUSED => e
        puts "Can not connect, sleep a while"
        sleep(30)
      end
    end
  end

  def post_connect
    #Set default presence to available
    #Start a new queue array
    @queue = []
    register_callbacks

    status = Presence.new.set_type(:available)
    @client.send(status)
  end

  def disconnect
    return unless @connected

    @exit = true
    @worker_thread.wakeup if @worker_thread
    @client.close if @client
  end

  # +klass+ - plugin class
  def add_plugin(klass)
    @cmd_map[klass] = klass.cmd_map if klass.cmd_map
  end

  def register_callbacks
    @client.add_message_callback do |message|
      @queue << message unless message.body.nil?
      @worker_thread.wakeup if @worker_thread
    end

    # The roster instance
    roster = Roster::Helper.new(@client)

    # Callback to handle updated roster items
    roster.add_update_callback do |olditem,item|
      if [:from, :none].include?(item.subscription) && item.ask != :subscribe
        puts("Subscribing to #{item.jid}")
        item.subscribe
      end
    end

    # Subscription requests and responses:
    subscription_callback = lambda do |item,pres|
      name = pres.from

      if item != nil && item.iname != nil
        name = "#{item.iname} (#{pres.from})"
      end

      case pres.type
      when :subscribe then
        puts("Subscription request from #{name}")
        # TODO check security
        roster.accept_subscription(pres.from)
      when :subscribed then puts("Subscribed to #{name}")
      when :unsubscribe then puts("Unsubscription request from #{name}")
      when :unsubscribed then puts("Unsubscribed from #{name}")
      else raise "The Roster Helper is buggy!!! subscription callback with type=#{pres.type}"
      end
    end

    roster.add_subscription_callback(0, nil, &subscription_callback)
    roster.add_subscription_request_callback(0, nil, &subscription_callback)
  end

  def send_command(task_id, recipient, cmd, &callback)
    message = Message.new(recipient)
    message.type = :chat
    message.id = task_id
    message.body = cmd

    add_task("r" << task_id, callback)

    @client.send(message)
  end

  def add_task(task_id, callback)
    @mutex.synchronize do
      @task_map[task_id] = callback
    end
  end

  def remove_task(task_id)
    @mutex.synchronize do
      @task_map.delete task_id
    end
  end

  def send_message(recipient, text)
    message = Message.new(recipient)
    message.type = :chat
    message.body = text
    @client.send(message)
  end

  def send_error_response(msg_in, body)
    reply = msg_in.answer(true)
    reply.type = :error
    reply.delete_element "html"
    reply.body = body
    @client.send(reply)
  end

  def send_cmd_response(orig_msg, body, subject = nil)
    answer = orig_msg.answer(true)
    answer.id = "r" << answer.id if answer.id =~ /^task/
    # pidgin sends html version also
    answer.delete_element "html"
    answer.body = body
    answer.subject = subject if subject
    send_raw(answer)
  end

  def send_raw(message)
    @client.send(message)
  end

  def list_plugins
    @cmd_map.keys.map {|x| x.name }.join ", "
  end

  def show_help_for(plugin_name)
    klass = @cmd_map.keys.detect {|p| p.name == plugin_name}

    if klass
      help_txt = klass.new.send(:help)
      msg = klass.name
      msg << " (#{klass.description})" if klass.description
      msg << "\n"
      msg << add_new_lines(help_txt)
    else
      msg = "Can not find plugin '#{plugin_name}'"
    end

    msg
  end

  def add_new_lines(arg)
    if arg.is_a?(Array)
      arg.join("\n")
    else
      arg
    end
  end

  def start_worker
    @worker_thread = Thread.new do
      puts "Started worker"
      #Start a loop to listen for incoming messages

      loop do
        break if @exit

        if !@queue.empty?
          @queue.each do |item|
            if func = @task_map[item.id]
              logger.debug("Sending task response #{item.id}")
              func.call(item)
            elsif run_cmd(item)
            elsif item.type == :error
              # ignore it
            else
              message = Message.new(item.from)
              message.type = :error
              message.body = "Was it only a simple message?! " + item.body.to_s
              @client.send(message)
            end

            @queue.shift
          end
        end

        sleep 60
      end
    end

    @worker_thread.join
  end

  def run_cmd(msg)
    body = msg.body

    for klass, commands_map in @cmd_map
      for regexp, cmd in commands_map
        if body =~ regexp
          obj = klass.new
          obj.agent = self
          obj.sender = msg.from
          obj.message = msg

          begin
            rez = obj.send(cmd, $~)

            if rez.is_a?(String) || rez.is_a?(Array)
              send_cmd_response(msg, add_new_lines(rez))
            end
          rescue => e
            error = "Command error:\n" << e.to_s << "\n" << e.backtrace.join("\n")
            send_error_response(msg, error)
          end

          return true
        end
      end
    end

    false
  end
end
