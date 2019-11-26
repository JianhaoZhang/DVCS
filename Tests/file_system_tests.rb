require "minitest/autorun"
require "open3"
require_relative "../file_system.rb"
#require_relative "t.rb"

#ARGV = ["this", "is", "a", "phrase"]
#load("t.rb")

class FS
  include FileSystem
end

class Test_p1 < Minitest::Test
  
  def setup
    if Dir.exist?("Project")
      system("rm -r Project")
    end
    system("mkdir Project \n cd Project \n touch new.txt\n")
    
  end
  def test_init

    output1 = ""

    Dir.chdir("Project") do
      output3, status = Open3.capture2("pwd")

      FileSystem.init()

      output1 = Open3.capture2("ls -a")

      
      assert Dir.exist?(".dvcs"), ".dvcs not created"
      assert File.file?(".dvcs/revision_history_file"), "revision history file not created"
      t = false
      assert FileSystem.init() == 0, "init should fail!"
    end

  end
  
  def test_clone
 
    Dir.chdir("Project") do
      FileSystem.init()
    end
    system("mkdir Temp")
    Dir.chdir("Temp") do
      FileSystem.clone("../Project")
    end
    output, status = Open3.capture2("diff Project Temp/Project")
    assert output.empty?, "Project cloned but incorrect/incomplete"
    
    
  end
  
  def test_store_get_rh
    Dir.chdir("Project") do
      FileSystem.init()
      b = ["line1", "line2", "line3", "line4"]
      n = ["nline1", "nline2", "nline3", "nline4"]
      #storing and then retriving data should not change the data
      FileSystem.store_rh(b)
      result = FileSystem.get_rh()
      assert_equal result, b
      # assert_equal result[0], b[0]
      #checking that storing ne data doesn't corrupt
      FileSystem.store_rh(n)
      result = FileSystem.get_rh()
      assert_equal result, n
    end
  end
  
  def test_diff
    s = "This is a random file\nline 2 is this"
    s1 = "This is another random file\nline 2 is this"
    Dir.chdir("Project") do
      
      File.open("a.txt", "w"){|f| f.write(s)}
      File.open("b.txt", "w"){|f| f.write(s)}
      File.open("c.txt", "w"){|f| f.write(s1)}
      assert FileSystem.diff("a.txt", "b.txt").empty?
      
      assert !FileSystem.diff("a.txt", "c.txt").empty?
    end
  end
  
  def test_read
    s = "some message here"
    Dir.chdir("Project") do
      
      File.open("a.txt", "w"){|f| f.write(s)}
      f = File.open("a.txt")
      assert_equal FileSystem.read("a.txt").to_a(), f.to_a()
    end
    
  end
  
  def test_write
    Dir.chdir("Project") do
      FileSystem.write("b.txt", "1 2 3 4 5")
      FileSystem.write("new.txt", "1 2 3 4 5")
      assert_equal ["1 2 3 4 5"], File.open("new.txt").to_a()
      
      assert_equal ["1 2 3 4 5"], File.open("b.txt").to_a()
    end
  end
  
  def test_cpy
    Dir.chdir("Project") do
      system("mkdir P1\n mkdir P2")
      File.open("a.txt", "w") {|f| f.write("the contents of the file\nline2\n")}
      system("mv a.txt P1")
      FileSystem.cpy("P1/a.txt", ".")
      FileSystem.cpy("P1", "P2")
      output, status = Open3.capture2("diff P1/a.txt a.txt")
      output2, status = Open3.capture2("diff P1 P2/P1")
      assert output.empty?
      assert output2.empty?
    end
  end
  
  def test_del
    Dir.chdir("Project") do
      system("mkdir Temp\n touch a.txt")
      FileSystem.delete("Temp")
      FileSystem.delete("a.txt")
      assert !File.exist?("Temp")
      assert !File.exist?("a.txt")
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



class FS
  include FileSystem
end


#puts("output is #{output}")
#puts("output is #{output2}")
#puts("output is #{output3}")