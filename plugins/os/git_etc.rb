#
# Author: Vitalie Lazu <vitalie.lazu@gmail.com>
# Date: Thu, 11 Dec 2008 10:57:21 +0200
#

module Os
  class GitEtc < SHelper::BasePlugin
    name "git-etc"
    description "This plugin will help you to maintain server /etc/ directory under git version control"
    version "1.0"
    author "Vitalie Lazu"

    # Help that will be shown in case admin will send message with body ":help git-etc"
    def help
      rez = ":ge setup - init .git directory in /etc folder\n"
      rez << ":ge diff - show diff for current changes\n"
      rez << ":ge commit COMMENT - will commit changes\n"
      rez << ":ge status - will run git status\n"
    end

    # hash with regexp and method to call if regexp is matched
    cmd_map \
    /^:ge\s+setup/i => :cmd_setup,
    /^:ge\s+diff/i => :cmd_diff,
    /^:ge\s+(ci|commit)\s+(.+)/i => :cmd_commit,
    /^:ge\s+(sta?t?u?s?)/i => :cmd_status

    def cmd_diff(msg)
      run_cmd("cd /etc && git diff")
    end

    def cmd_status(msg)
      run_cmd("cd /etc && git status")
    end

    # params: cmd, commit message
    def cmd_commit(msg)
      comment = msg[2].tr('"', '')
      run_cmd("cd /etc;git add . && git commit -a -m \"#{comment}\"")
    end

    def cmd_setup(msg)
      unless test(?d, "/etc/.git")
        run_cmd("cd /etc && git init")
      end

      run_cmd "chmod 0700 /etc/.git"
    end
  end
end

# Register our plugin in the framework
SHelper.register_plugin Os::GitEtc
