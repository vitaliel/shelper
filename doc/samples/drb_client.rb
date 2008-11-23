
require 'drb'

connector = DRbObject.new(nil, "druby://localhost:5677")

p connector.send_message("xawerty", "desktop@localhost", ":stats load")
