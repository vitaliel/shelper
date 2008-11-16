
module Os
  class Gem < SHelper::BasePlugin
    name "gem"
    description "plugin to install/remove ruby gems"

    cmd_map /^:gem\s+(install|remove)\s+([A-Za-z0-9\-]+)/ => :gem,
        /^:gem\s+list\s+local/ => :list_local

    def help
      rez = ""
      rez << ":gem install gem_name - will install the gem_name\n"
      rez << ":gem remove  gem_name - will remove all gem_name versions\n"
      rez << ":gem list local - will display local gems\n"
    end

    def gem(msg)
      run_cmd("gem #{msg[1]} #{msg[2]}")
    end

    def list_local(msg)
      run_cmd("gem list --local")
    end
  end
end

SHelper.register_plugin Os::Gem
