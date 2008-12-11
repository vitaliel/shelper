#
# Author: Vitalie Lazu <vitalie.lazu@gmail.com>
# Date: Thu, 11 Dec 2008 10:57:21 +0200
#

module Os
  # Replacement for nagios-statd-server
  class Stats < SHelper::BasePlugin
    name "stats"
    description "plugin to check server statistics, like load, free disk space, etc"
    author 'Vitalie Lazu'

    cmd_map \
    /^:stats\s+load/ => :load

    def help
      rez = ""
      rez << ":stats load - will display server load average\n"
    end

    def load(msg)
      file = "/proc/loadavg"
      load_avg = []

      if test ?r, file
        File.open(file) do |f|
          load_avg = f.read.strip.split(/\s+/, 4)[0..2]
        end
      else
        load_avg = `uptime`.strip.split(/load averages?:/)[1].tr(' ','').split ','
      end

      send_response(load_avg * ' ')
    end
  end
end

SHelper.register_plugin Os::Stats
