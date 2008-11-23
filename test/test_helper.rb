require 'test/unit'
require 'rubygems'
require 'mocha'

$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'shelper'

module SHelper
  class << self
    def register_plugin(klass)
    end
   end
end
