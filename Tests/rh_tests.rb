require "minitest/autorun"
require "open3"
require_relative "../RevisionHistor.rb"

class Test_p1 < Minitest::Test
  def setup
    if Dir.exist?("Project")
      system("rm -r Project")
    end
    system("mkdir Project \n cd Project \n touch new.txt\n")
    
  end
  def test_init
    rh = RevisionHistory.new(Dir.pwd, true)
    puts rh.log()
    assert true
  end
  def teardown
    if Dir.exist?("Project")
      system("rm -r Project")
    end
    if Dir.exist?("Temp")
      system("rm -r Temp")
    end
  end
end