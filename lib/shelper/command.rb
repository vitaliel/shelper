#
# Author: Vitalie Lazu <vitalie.lazu@gmail.com>
# Date: Thu, 27 Nov 2008 16:10:04 +0200
#

require 'thread'

module SHelper;end

class SHelper::Command
  #
  def initialize(cmd, delay = 1, &block)
    @cb = block
    @cmd = cmd
    @delay = delay
    @parent_to_child_read, @parent_to_child_write = IO.pipe
    @child_to_parent_read, @child_to_parent_write = IO.pipe

    @child_pid = fork do
      @parent_to_child_write.close
      @child_to_parent_read.close
      $stdin.reopen(@parent_to_child_read)
      $stdout.reopen(@child_to_parent_write)
      $stderr.reopen(@child_to_parent_write)
      exec(@cmd)
    end

    buffer = ""
    semaphore = Mutex.new

    Thread.new do
      while true
        c = @child_to_parent_read.read(1)
        semaphore.synchronize { buffer += c }
      end
    end

    Thread.new do
      ch = ""

      while true do
        sleep @delay

        semaphore.synchronize {
          if buffer == ch and ch != ""
            @cb.call buffer
            buffer = ""
          end

          ch = buffer
        }
      end
    end
  end

  def puts(str)
    @parent_to_child_write.puts(str)
  end

  def wait
    Process.wait2
  end

  def kill
    @child_pid.kill
  end
end
