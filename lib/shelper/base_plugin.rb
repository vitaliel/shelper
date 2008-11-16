
module SHelper;end

class SHelper::BasePlugin
  include Annotatable

  annotate :version, :name, :url, :description, :author

  attr_writer :agent

  # Will be called to init the plugin
  # Plugin should return a hash with regexp and associated command
  def init

  end

  # Provide help how to use this plugin
  def help

  end
end
