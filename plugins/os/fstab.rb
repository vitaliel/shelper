require 'fileutils'

module Os
  class Fstab < SHelper::BasePlugin
    name "fstab"
    description "plugin to modify /etc/fstab"
    author "Vitalie Lazu"
    version "1.0"

    cmd_map \
    /^:fstab\s+list/ => :fs_list,
    /^:fstab\s+remove\s+([a-zA-Z0-9\/]+)/ => :fs_remove,
    /^:fstab\s+add-nfs\s+([a-zA-Z0-9.-]+)\s+([a-zA-Z0-9\/-_]+)\s+([a-zA-Z0-9\/-_]+)\s*([a-z0-9,=]+)?/ => :fs_add_nfs

    def help
      rez = ""
      rez << ":fstab list - will export path to the client\n"
      rez << ":fstab remove MOUNT_POINT - will remove mount_point from /etc/fstab\n"
      rez << ":fstab add-nfs SERVER EXPORTED_DIR MOUNT_POINT [OPTIONS] - add nfs mount info to /etc/fstab\n"
    end

    # Parameters: mount_point
    def fs_remove(msg)
      mount_point = msg[1]
      mounts = parse_fstab(fstab_content)

      found = mounts.detect {|x| x[:mount_point] == mount_point }

      if found
        file_util("/etc/fstab").remove_line(mount_point)
        message = "#{mount_point} was removed from fstab"
      else
        message = "Mount point #{mount_point.inspect} not found in fstab"
      end

      send_response(message)
    end

    # Parameters: server, exported_path, local_mount, options
    def fs_add_nfs(msg)
      options = msg[4]

      unless options
        options = "rsize=8192,tcp,noatime,nodev,sync"
      end

      mount_point = msg[3]
      line = "#{msg[1]}:#{msg[2]} #{mount_point} nfs #{options} 0 2\n"
      mounts = parse_fstab(fstab_content)

      found = mounts.detect {|x| x[:mount_point] == mount_point }
      file = "/etc/fstab"

      unless found
        FileUtils.mkdir_p mount_point unless test ?d, mount_point

        file_util(file).add_line(line)
        message = "Added #{line.strip} to #{file}."
      else
        message = "Mount point #{msg[3]} is already in #{file}"
      end

      send_response(message)
    end

    def fs_list(msg)
      send_response(fstab_content)
    end

    def fstab_content
      File.open("/etc/fstab") do |f|
        return f.read
      end
    end

    # <file system> <mount point>   <type>  <options>       <dump>  <pass>
    def parse_fstab(file_content)
      # exclude comments and blank lines
      text_lines = file_content.split(/\n/).reject {|x| x =~ /^((\s*#.*)|(\s*))$/ }
      rez = []

      for line in text_lines
        parts = line.split
        h = {}

        %w{fs mount_point type options dump pass}.each_with_index do |el, idx|
          h[el.to_sym] = parts[idx]
        end

        rez << h
      end

      rez
    end
  end
end

SHelper.register_plugin Os::Fstab
