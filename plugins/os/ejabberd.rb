#
# Date: Mon, 24 Nov 2008 12:29:52 +0200
#

module Os
  # Replacement for nagios-statd-server
  class Ejabberd < SHelper::BasePlugin
    name "ejabberd"
    description "plugin to register users on ejabberd service."
    author 'Vitalie Lazu'

    cmd_map \
    /^:ej\s+del\s+([a-z0-9]+)\s+([a-z0-9.-]+)/ => :ej_unregister,
    /^:ej\s+add\s+([a-z0-9]+)\s+([a-z0-9.-]+)/ => :ej_register

    def help
      rez = ""
      rez << ":ej add USERNAME DOMAIN - will register a new user with random password\n"
      rez << ":ej del USERNAME DOMAIN - will register a new user with random password\n"
    end

    # Parameters: username, domain
    def ej_unregister(msg)
      run_cmd "ejabberdctl unregister #{msg[1]} #{msg[2]}"
    end

    # Parameters: username, domain
    def ej_register(msg)
      chars = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890-_"
      password = ""
      12.times { password << chars[rand(chars.length)] }

      run_cmd "ejabberdctl register #{msg[1]} #{msg[2]} #{password}"
      send_response("Password: " << password)
    end
  end
end

SHelper.register_plugin Os::Ejabberd
