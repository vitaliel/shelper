
module Os
  class Nfs < SHelper::BasePlugin
    name "nfs"
    description "plugin to help with nfs export operations"
    author "Vitalie Lazu"
    version "1.0"

    cmd_map \
    /^:nfs\s+reload/ => :reload,
    /^:nfs\s+export\s+(\/[a-z0-9\/]+)\s+(rw|ro)\s+([a-zA-Z0-9.]+)/ => :nfs_export

    def help
      rez = ""
      rez << ":nfs export PATH ro|rw client - will export path to the client\n"
      rez << ":nfs reload - reload info from /etc/exports\n"
    end

    # $1 - path, $2 read/write mode, $3 - client
    def nfs_export(msg)
      file = "/etc/exports"
      line = "#{msg[1]} #{msg[3]}(#{msg[2]},sync,no_subtree_check)\n"

      lines = []
      found = false

      File.open(file) do |f|
        for l in f.readlines
          if l == line
            found = true
            break
          end
        end
      end

      unless found
        # TODO ask agent to backup original file

        File.open(file, "a") do |f|
          f.write line
        end

        message = "Added #{line.strip} to #{file}."
        reload(nil)
      else
        message = "#{line.strip} is already in #{file}"
      end

      send_response(message)
    end

    def reload(msg)
      run_cmd("/usr/sbin/exportfs -r")
    end
  end
end

SHelper.register_plugin Os::Nfs
