require 'digest'
require "minitest/autorun"
require "open3"
require_relative "../RevisionHistory.rb"

class Test_p1 < Minitest::Test
  def setup
    if Dir.exist?("Project")
      system("rm -r Project")
    end
    system("mkdir Project \n cd Project \n touch new.txt\n")
    
  end
  def test_init_new

    Dir.chdir("Project") do
      rh = RevisionHistory.new(Dir.pwd, true)
      assert_equal "Revision history is empty.", rh.log()
      
    end
  end
  
  def test_commit
    
    Dir.chdir("Project") do
      rh = RevisionHistory.new(Dir.pwd, true)
      assert_equal "Revision history is empty.", rh.log()
      rh.add("new.txt")
      File.open("new.txt", "w") {|f| f.write("Something here")}
      rh.setCommitMsg("Commit 1\nSecond Line")
      rh.commit()
      puts rh.log()
      #puts "after log"
      
      File.open("new.txt", "w"){|f| f.write("1 2 3 4 5\n 1234 \n 123 \n12 \n1")}
      #puts File.open("new.txt", "r") {|f| f.read()}
      rh.add("new.txt")
      
      #puts rh.heads()
      #puts rh.status()
      rh.setCommitMsg("Commit 2\nSecond Line")
      rh.commit()
      log = rh.log()
      puts "This is log 1"
      puts log
      
      rh.rh2Text()
      
      rh2 = RevisionHistory.new(Dir.pwd, false)
      log2 = rh2.log()
      puts "This is log 2"
      puts log2
      puts "End log 2"
      assert_equal log, log2
      assert true
    end
  end
  
  def test_init_file
    
    Dir.chdir("Project") do
      rh = RevisionHistory.new(Dir.pwd, true)
      assert_equal "Revision history is empty.", rh.log()
      rh.add("new.txt")
      rh.commit()
      puts rh.log()
      File.open("new.txt", "w"){|f| f.write("1 2 3 4 5")}
    end
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

