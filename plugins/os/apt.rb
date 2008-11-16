
module Os
  class Apt < SHelper::BasePlugin
    name "apt"
    description "plugin to install/remove debian packages"

    cmd_map /^:apt\s+(install|remove)\s+([A-Za-z0-9\-]+)/ => :apt,
        /^:apt\s+search\s+([^\s]+)/ => :list_packages

    def help
      rez = ""
      rez << ":apt install|remove pkg_name - will install/remove the pkg_name\n"
      rez << ":apt search pattern - will display packages that match pattern\n"
    end

    def apt(msg)
      run_cmd("apt-get -y #{msg[1]} #{msg[2]}")
    end

    def list_packages(msg)
      run_cmd("dpkg -l '*#{msg[1]}*'")
    end
  end
end

SHelper.register_plugin Os::Apt
