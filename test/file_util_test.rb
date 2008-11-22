require File.dirname(__FILE__) + "/test_helper"

require 'shelper/file_util'
require 'stringio'
require 'tempfile'

class FileUtilTest < Test::Unit::TestCase

  def test_append_to_lines
    f = Tempfile.new("test")
    f.write "# hello\nacl: 127.0.0.1\npath:/tmp\n"
    f.close

    fu = SHelper::FileUtil.new(f.path)
    fu.append_to_lines(/^acl:/, " 127.0.0.5")

    f.open
    assert_equal "# hello\nacl: 127.0.0.1 127.0.0.5\npath:/tmp\n", f.read
    f.close!
  end
end
