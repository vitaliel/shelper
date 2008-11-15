module SHelper;end

class SHelper::Agent
  include Jabber

  def initialize
    user = JID.new("#{configatron.xmpp.username}/XMPPAgent")
    @password = configatron.xmpp.password
    @client = Client.new(user)
  end

  def connect
    #Connect to server sending username and password
    @client.connect(configatron.xmpp.server_name, configatron.xmpp.port)
    @client.auth(@password)

    post_connect if @client
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
    @client.close if @client
  end

  def register_callbacks
    @client.add_message_callback do |message|
      @queue << message unless message.body.nil?
    end

    versions = {}

#     @client.add_presence_callback do |pres|
#       # Already fingerprinted or offline?
#       unless versions.has_key?(pres.from) || (pres.type == :unavailable) || (pres.type == :error)
#         # Construct a new query
#         iq = Iq.new(:get, pres.from)
#         # and ask for the version
#         iq.query = Version::IqQueryVersion.new
#         puts "Asking #{iq.to} for his/her/its version"
#         versions[pres.from] = :asking
#         cl.send(iq)
#       end
#     end

    # The roster instance
    roster = Roster::Helper.new(@client)

    # Subscription requests and responses:
    subscription_callback = lambda do |item,pres|
      name = pres.from

      if item != nil && item.iname != nil
        name = "#{item.iname} (#{pres.from})"
      end

      case pres.type
      when :subscribe then
        p pres.from
        puts("Subscription request from #{name}")

        Thread.new do
          roster.accept_subscription(pres.from)
        end
      when :subscribed then puts("Subscribed to #{name}")
      when :unsubscribe then puts("Unsubscription request from #{name}")
      when :unsubscribed then puts("Unsubscribed from #{name}")
      else raise "The Roster Helper is buggy!!! subscription callback with type=#{pres.type}"
      end
    end

    roster.add_subscription_callback(0, nil, &subscription_callback)
    roster.add_subscription_request_callback(0, nil, &subscription_callback)
  end

  def send_message(recipient, text, reply=false)
    message = Message.new(recipient)
    message.type = :chat

    if reply
      message.body = "Thank you for sending me the message: " << text
    else
      message.body = text
    end

    @client.send(message)
  end

  def start_worker_thread
    worker_thread = Thread.new do
      puts "Started new worker thread"
      #Start a loop to listen for incoming messages

      loop do
        if !@queue.empty?
          @queue.each do |item|
            puts item
            #Remove the resource from the user, e.g., carlos@xmppserver/exodus = carlos@xmppserver
            sender = item.from.to_s.sub(/\/.+$/, '')

            #If the message included the line command: create a new command object and attempt to run it
            if item.body.include? "command: "
              send_message(sender, "I'll try to run " << item.body.to_s, false)
              input_command = SHelper::Command.new
              command_result = input_command.run_command(item.body.to_s)
              send_message(sender, command_result, false)
            else
              send_message(sender, item.body.to_s, true)
            end

            @queue.shift
            puts "Queue is now empty" if @queue.empty?
          end
        end
      end

      sleep 1
    end

    worker_thread.join
  end
end
