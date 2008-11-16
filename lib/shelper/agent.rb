
module SHelper;end

class SHelper::Agent
  include Jabber

  def initialize
    user = JID.new("#{configatron.xmpp.username}/SHelperAgent")
    @password = configatron.xmpp.password
    @client = Client.new(user)
    @cmd_map = {}
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

  # +obj+ - to which object send message
  # +cmd_map+ - hash with key regexp and value method name as symbol, each matched message will be passed to obj.send(:method, msg)
  def add_plugin(obj, cmd_map)
    @cmd_map[obj] = cmd_map
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

  def send_message(recipient, text, reply = false)
    message = Message.new(recipient)
    message.type = :chat

    if reply
      message.body = "Received message: " << text
    else
      message.body = text
    end

    @client.send(message)
  end

  def list_plugins
    rez = @cmd_map.keys.map {|x| x.name }.join ", "
    send_message(configatron.admin.jid, rez)
  end

  def show_help_for(plugin_name)
    obj = @cmd_map.keys.detect {|p| p.name == plugin_name}

    if obj
      help_txt = obj.send(:help)
      msg = "#{obj.name} (#{obj.description})\n" << help_txt
    else
      msg = "Can not find plugin '#{plugin_name}'"
    end

    # TODO send to user that sent message/command, make a map with message_id:recipient
    send_message(configatron.admin.jid, msg)
  end

  def start_worker
    @worker_thread = Thread.new do
      puts "Started worker"
      #Start a loop to listen for incoming messages

      loop do
        break if @exit

        if !@queue.empty?
          @queue.each do |item|
            # Remove the resource from the user, e.g., user@example.com/home = user@example.com
            sender = item.from.to_s.sub(/\/.+$/, '')
            body = item.body

            unless run_cmd(body)
              send_message(sender, "Was it only a simple message?! " + item.body.to_s, true)
            end

            @queue.shift
            # puts "Queue is now empty" if @queue.empty?
          end
        end

        sleep 10
      end
    end

    @worker_thread.join
  end

  def run_cmd(body)
    for obj, commands_map in @cmd_map
      for regexp, cmd in commands_map
        if body =~ regexp
          obj.send(cmd, $~)
          return true
        end
      end
    end

    false
  end
end
