module SHelper;end

class SHelper::Command
  @@allowable_commands = %w{ifconfig ping dig}

  def run_command(command)
    #Strip the command part out of the string - we don't need it any more.
    command.slice!("command: ")

    #Create an array for the arguments
    arguments = command.split(" ")
    arguments.delete_at(0) # Delete the first index, this is the command itself without arguments
    arguments.each {|x| puts "Argument: #{x}"}

    #Loop through the arguments and delete them from the command string
    arguments.each {|x| command.slice!(x)}

    puts "This is the command after munging #{command.strip!}"

    if @@allowable_commands.include? command
      puts "#{command} is an allowed command"
      result = `#{command} #{arguments.join(" ")}` #Backticks are a shortcut for system("commandhere"). Join the arguments back in.
    else
      result = "#{command} cannot be run"
    end

    puts result
    return result
  end
end
