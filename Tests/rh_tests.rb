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
      
      assert_equal log, log2
      
      
    end
  end
  
  def test_getfile
    Dir.chdir("Project") do
      rh = RevisionHistory.new(Dir.pwd, true)
      rh.add("new.txt")
      File.open("new.txt", "w") {|f| f.write("Something here")}
      original_file =  File.read("new.txt")
      rh.setCommitMsg("Commit 1")
      rh.commit()
      
      File.open("new.txt", "w"){|f| f.write("1 2 3 4 5\n 1234 \n 123 \n12 \n1")}
      #puts File.open("new.txt", "r") {|f| f.read()}
      rh.add("new.txt")
      
      #puts rh.heads()
      #puts rh.status()
      rh.setCommitMsg("Commit 2")
      rh.commit()
      #puts rh.log()
      
      f = rh.getFile("new.txt", 1)
      assert_equal original_file, f
    end
  end
  
  def test_diff
    Dir.chdir("Project") do
      rh = RevisionHistory.new(Dir.pwd, true)
      rh.add("new.txt")
      File.open("new.txt", "w") {|f| f.write("Something here")}
      File.open("a.txt", "w") {|f| f.write("a.txt")}
      rh.add("a.txt")
      rh.commit()
      
      rh.delete("a.txt")
      File.open("new.txt", "w") {|f| f.write("This File has been edited")}
      File.open("b.txt", "w") {|f| f.write("b.txt")}
      rh.add("b.txt")
      rh.add("new.txt")
      rh.commit()
      puts "printing diff"
      puts rh.diff(1, 1)
      puts "end print"
      assert rh.diff(1, 1) == [nil, nil, nil, nil], "Expected No Changes"
      assert [nil, nil, nil, nil] != rh.diff(1, 2), "Expected Changes"
      
    end
  end
  
  def test_status
    
    Dir.chdir("Project") do
      rh = RevisionHistory.new(Dir.pwd, true)
      rh.add("new.txt")
      File.open("new.txt", "w") {|f| f.write("Something here")}
      File.open("b.txt", "w") {|f| f.write("File b")}
      rh.add("b.txt")
      
      rh.setCommitMsg("Commit 1")
      rh.commit()
      assert_equal "No changes in current repository", rh.status()
    
      File.open("a.txt", "w") {|f| f.write("Another file")}
      rh.delete("b.txt")
      File.delete("b.txt")
      File.open("new.txt", "w") {|f| f.write("This is an edited file")}
      rh.add("a.txt")
      rh.add("new.txt")
      status = rh.status()
      #puts status
      assert_equal "Added file(s):\n[\"a.txt\"]\nDeleted file(s):\n[\"b.txt\"]\nModified file(s):\n[\"new.txt\"]", status
    end
  end
  

  def test_checkout
    Dir.chdir("Project") do
      rh = RevisionHistory.new(Dir.pwd, true)
      rh.add("new.txt")
      File.open("new.txt", "w") {|f| f.write("Something here")}
      original_file =  File.read("new.txt")
      rh.setCommitMsg("Commit 1")
      rh.commit()
      
      File.open("new.txt", "w"){|f| f.write("1 2 3 4 5\n 1234 \n 123 \n12 \n1")}
      #puts File.open("new.txt", "r") {|f| f.read()}
      rh.add("new.txt")
      
      #puts rh.heads()
      #puts rh.status()
      rh.setCommitMsg("Commit 2")
      rh.commit()
      #puts rh.log()
      
      rh.checkout(1)
      assert_equal original_file, File.read("new.txt")
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

