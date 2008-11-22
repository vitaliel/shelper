module Os
  class Mount < SHelper::BasePlugin
    name "mount"
    description "plugin to mount/umount file systems"
    author "Vitalie Lazu"
    version "1.0"

    cmd_map \
    /^:mount\s+list/ => :mount_list,
    /^:mount\s+(add|del)\s+(\/[a-zA-Z0-9\/]+)/ => :mount_add_remove

    def help
      rez = ""
      rez << ":mount list - will list mounted partitions\n"
      rez << ":mount add|del MOUNT_POINT - will mount/umount mount_point from /etc/fstab\n"
    end

    # Parameters: cmd, mount_point
    def mount_add_remove(msg)
      op = msg[1]
      mount_point = msg[2]
      cmd = (op == "add" ? "mount" : "umount") << " " << mount_point

      run_cmd cmd
    end

    def mount_list(msg)
      run_cmd "mount"
    end
  end
end

SHelper.register_plugin Os::Mount
