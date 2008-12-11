#
# Author: Vitalie Lazu <vitalie.lazu@gmail.com>
# Date: Thu, 11 Dec 2008 10:57:21 +0200
#

module Os
  class Apt < SHelper::BasePlugin
    name "apt"
    description "plugin to install/remove debian packages"

    cmd_map \
    /^:aptd\s+(update|upgrade|dist-upgrade)/ => :apt_dry_run,
    /^:aptd\s+(install|remove)\s+([A-Za-z0-9\-_]+)/ => :apt_dry_run_install,
    /^:apt\s+(install|remove)\s+([A-Za-z0-9\-_]+)/ => :apt,
    /^:apt\s+(clean|update|upgrade|dist-upgrade)/ => :apt_update,
    /^:apt\s+search\s+([^\s]+)/ => :list_packages

    def help
      rez = ""
      rez << ":aptd update|upgrade|dist-upgrade - will run apt-get with argument passed in dry-run mode\n"
      rez << ":aptd install|remove pkg_name - will install/remove the pkg_name in dry-run mode\n"
      rez << "\n"
      rez << ":apt clean|update|upgrade|dist-upgrade - will run apt-get with argument passed\n"
      rez << ":apt install|remove pkg_name - will install/remove the pkg_name\n"
      rez << ":apt dry-run-install pkg_name - will not perform real operations, just will show what it will do\n"
      rez << ":apt search pattern - will display packages that match pattern\n"
    end

    # Parameters: operation
    def apt_dry_run(msg)
      run_apt("-s #{msg[1]}")
    end

    # Parameters: operation, package
    def apt_dry_run_install(msg)
      run_apt("-s #{msg[1]} #{msg[2]}")
    end

    def apt_update(msg)
      run_apt("-qq #{msg[1]}")
    end

    def apt(msg)
      run_apt("-qq #{msg[1]} #{msg[2]}")
    end

    def list_packages(msg)
      run_cmd("dpkg -l '*#{msg[1]}*'")
    end

    def run_apt(params)
      cmd = "apt-get -y"
      run_cmd("#{cmd} #{params}")
    end
  end
end

SHelper.register_plugin Os::Apt
