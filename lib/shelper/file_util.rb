module SHelper
  # File operations like:
  # remove line that match substring or regexp
  # add line at end
  # TODO
  # comment line
  # un-comment line
  class FileUtil
    attr_accessor :backup_store

    def initialize(file_path)
      @file_path =file_path
    end

    # Remove lines from file that match regexp or substring
    # +match+ - regexp or substring
    # Returns true if file was modified, otherwise false
    def remove_line(match)
      func = nil

      if match.is_a?(Regexp)
        func = Proc.new { |x| x =~ match }
      else
        func = Proc.new { |x| x.index(match) }
      end

      lines = []
      modified = false

      open do |f|
        all_lines = f.readlines

        for line in all_lines
          unless func.call(line)
            lines << line
          end
        end

        if all_lines.size != lines.size
          modified = true
        end
      end

      if modified
        # TODO copy original file to backup store

        write do |f|
          f.write lines.join
        end
      end

      modified
    end

    # Append text to matched lines
    def append_to_lines(regexp, str)
      modified = false
      lines = []

      open do |f|
        all_lines = f.readlines

        for line in all_lines
          if line =~ regexp
            lines << (line.chomp << str << "\n")
            modified = true
          else
            lines << line
          end
        end
      end

      write do |f|
        f.write lines.join
      end if modified

      modified
    end

    def add_line(line)
      # TODO backup

      File.open(@file_path, "a") do |f|
        f.write line
        f.write "\n" unless line =~ /\n$/
      end
    end

    protected
    def open(&block)
      File.open(@file_path) do |f|
        block.call(f)
      end
    end

    def write(&block)
      File.open(@file_path, "w") do |f|
        block.call(f)
      end
    end
  end
end
