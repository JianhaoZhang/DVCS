require 'digest'
require "minitest/autorun"
require "open3"
require "fileutils"
require_relative "../general_utility.rb"
require_relative "../RevisionHistory.rb"
require_relative "../file_system.rb"

class GU
  include GeneralUtility
end

class Test_p1 < Minitest::Test
  
  def setup
    
    if Dir.exist?("Project")
      system("rm -r Project")
    end
    if Dir.exist?("Temp")
      system("rm -r Temp")
    end
    system("mkdir Project \n cd Project \n touch new.txt\n")
    system("mkdir Temp")
  end
  
  def test_push
    rh = nil
     
    gu = GU.new()
    #rh = RevisionHistory.new(Dir.pwd + "/Project", true)
    Dir.chdir("Project") do
      rh = RevisionHistory.new(Dir.pwd, true)
      File.open("new.txt", "w"){|f| f.write("Contents of the file")}
      rh.add("new.txt")
      rh.commit()
      rh.rh2Text()
    end
    Dir.chdir("Temp") do
      FileSystem.clone("../Project")
    end
    
    Dir.chdir("Project") do
      File.open("new.txt", "w"){|f| f.write("Contents of the file after and edit was made")}
      rh.add("new.txt")
      rh.commit()
      rh.rh2Text()
      
      assert_raises StandardError do
        gu.push("../Temp")
      end
      
      gu.push("../Temp/Project")
      output, status = Open3.capture2("diff new.txt ../Temp/Project/new.txt")
      assert output.empty?, "push failed to copy files correctly"
    end
  
  end
 
  def test_pull
    rh = nil
     
    gu = GU.new()
    #rh = RevisionHistory.new(Dir.pwd + "/Project", true)
    Dir.chdir("Project") do
      rh = RevisionHistory.new(Dir.pwd, true)
      File.open("new.txt", "w"){|f| f.write("Contents of the file")}
      rh.add("new.txt")
      rh.commit()
      rh.rh2Text()
    end
    Dir.chdir("Temp") do
      FileSystem.clone("../Project")
    end
    
    Dir.chdir("Project") do
      File.open("new.txt", "w"){|f| f.write("Contents of the file after and edit was made")}
      rh.add("new.txt")
      rh.commit()
      rh.rh2Text()
    end
    
    Dir.chdir("Temp/Project") do
      assert_raises StandardError do
        gu.pull("..")
      end
      
      gu.pull("../../Project")
      output, status = Open3.capture2("diff new.txt ../../Project/new.txt")
      assert output.empty?, "pull failed to copy files correctly"
    end
  end
  
  # def test_merge
    
  #   rh = nil
     
  #   gu = GU.new()
  #   #rh = RevisionHistory.new(Dir.pwd + "/Project", true)
  #   Dir.chdir("Project") do
  #     rh = RevisionHistory.new(Dir.pwd, true)
  #     File.open("new.txt", "w"){|f| f.write("Contents of the file")}
  #     rh.add("new.txt")
  #     rh.commit()
  #     rh.rh2Text()
  #   end
  #   Dir.chdir("Temp") do
  #     FileSystem.clone("../Project")
  #     Dir.chdir("Project") do
  #       rh2 = RevisionHistory.new(Dir.pwd, false)
  #       File.open("a.txt", "w"){|f| f.write("contents of file a.txt")}
  #       rh2.add("a.txt")
  #       rh2.commit()
  #       rh.rh2Text()
  #     end
  #   end
    
  #   Dir.chdir("Project") do
  #     File.open("b.txt", "w") {|f| f.write("Contents of file b.txt")}
  #     rh.add("b.txt")
  #     rh.commit()
  #     rh.rh2Text()
  #     #pull to force an implicit merge
  #     gu.pull("../Temp/Project")
  #     output, status = Open3.capture2("diff a.txt ../Temp/Project/a.txt")
  #     assert output.empty?, "Failed to keep files in merge"
  #     output, status = Open3.capture2("diff b.txt ../Temp/Project/b.txt")
  #     assert output.empty?, "Failed to transfer files in merge"
  #   end
  # end
  
  def teardown 
    if Dir.exist?("Project")
      system("rm -r Project")
    end
    if Dir.exist?("Temp")
      system("rm -r Temp")
    end
   
  end
end
  