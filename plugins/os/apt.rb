
module Os
  class Apt < SHelper::BasePlugin
    name "apt"
    description "plugin to install/remove debian packages"

    cmd_map /^:apt\s+(install|remove)\s+([A-Za-z0-9\-_]+)/ => :apt,
        /^:apt\s+dry-run-install\s+([A-Za-z0-9\-_]+)/ => :apt_dry_run,
        /^:apt\s+(update|upgrade|dist-upgrade)/ => :apt_update,
        /^:apt\s+search\s+([^\s]+)/ => :list_packages

    def help
      rez = ""
      rez << ":apt update|upgrade|dist-upgrade - will run apt-get with argument passed\n"
      rez << ":apt install|remove pkg_name - will install/remove the pkg_name\n"
      rez << ":apt dry-run-install pkg_name - will not perform real operations, just will show what it will do\n"
      rez << ":apt search pattern - will display packages that match pattern\n"
    end

    def apt_upgrade(msg)
      run_cmd("apt-get -y -qq #{msg[1]}")
    end

    def apt(msg)
      run_cmd("apt-get -y -qq #{msg[1]} #{msg[2]}")
    end

    def apt_dry_run(msg)
      run_cmd("apt-get -y -s install #{msg[1]}")
    end

    def list_packages(msg)
      run_cmd("dpkg -l '*#{msg[1]}*'")
    end
  end
end

SHelper.register_plugin Os::Apt
