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
  
  def test_merge
    
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
      Dir.chdir("Project") do
        rh2 = RevisionHistory.new(Dir.pwd, false)
        File.open("a.txt", "w"){|f| f.write("contents of file a.txt")}
        rh2.add("a.txt")
        rh2.commit()
        rh2.rh2Text()
      end
    end
    
    Dir.chdir("Project") do
      File.open("b.txt", "w") {|f| f.write("Contents of file b.txt")}
      rh.add("b.txt")
      rh.commit()
      rh.rh2Text()
      #pull to force an implicit merge
      gu.pull("../Temp/Project")
      output, status = Open3.capture2("diff a.txt ../Temp/Project/a.txt")
      assert output.empty?, "Failed to keep files in merge"
      output, status = Open3.capture2("diff b.txt ../Temp/Project/b.txt")
      assert output.empty?, "Failed to transfer files in merge"
    end
  end

  def test_merge_2
    
    rh = nil
    rh2 = nil

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
      Dir.chdir("Project") do
        rh2 = RevisionHistory.new(Dir.pwd, false)
        File.open("a.txt", "w"){|f| f.write("contents of file a.txt")}
        rh2.add("a.txt")
        rh2.commit()
        File.open("c.txt", "w"){|f| f.write("contents of file c.txt")}
        rh2.add("c.txt")
        rh2.commit()
        rh2.rh2Text()
      end
    end
    
    Dir.chdir("Project") do
      File.open("b.txt", "w") {|f| f.write("Contents of file b.txt")}
      rh.add("b.txt")
      File.open("d.txt", "w") {|f| f.write("Contents of file d.txt")}
      rh.add("d.txt")
      rh.commit()
      rh.delete("b.txt")
      rh.commit()
      rh.rh2Text()
      #pull to force an implicit merge
      gu.pull("../Temp/Project")
      output, status = Open3.capture2("diff a.txt ../Temp/Project/a.txt")
      assert output.empty?, "Failed to keep files in merge"
      output, status = Open3.capture2("diff b.txt ../Temp/Project/b.txt")
      assert output.empty?, "Failed to delete files in merge"
      output, status = Open3.capture2("diff d.txt ../Temp/Project/d.txt")
      assert output.empty?, "Failed to transfer files in merge"
    end
  end

  def test_merge_conflict
    
    rh = nil
    rh2 = nil
     
    gu = GU.new()
    #rh = RevisionHistory.new(Dir.pwd + "/Project", true)
    Dir.chdir("Project") do
      rh = RevisionHistory.new(Dir.pwd, true)
      File.open("Bool.hs", "w"){|f| f.write("boolean")}
      rh.add("Bool.hs")
      File.open("Array.hs", "w"){|f| f.write("array here")}
      rh.add("Array.hs")
      File.open("King.hs", "w"){|f| f.write("king is mark")}
      rh.add("King.hs")
      File.open("Mark.hs", "w"){|f| f.write("mark is king")}
      rh.add("Mark.hs")
      rh.commit()
      rh.rh2Text()
    end
    Dir.chdir("Temp") do
      FileSystem.clone("../Project")
      Dir.chdir("Project") do
        rh2 = RevisionHistory.new(Dir.pwd, false)
        File.open("Bool.hs", "w"){|f| f.write("boolean modified!")}
        rh2.add("Bool.hs")
        rh2.delete("Mark.hs")
        File.open("Whale.hs", "w"){|f| f.write("whale is swimming")}
        rh2.add("Whale.hs")
        rh2.commit()
        rh2.rh2Text()
      end
    end
    
    Dir.chdir("Project") do
      File.open("Bool.hs", "w"){|f| f.write("boolean not modified (no)!")}
      rh.add("Bool.hs")
      File.open("Whale.hs", "w"){|f| f.write("whale is dying")}
      rh.add("Whale.hs")
      rh.delete("Array.hs")
      rh.commit()
      rh.rh2Text()
      #pull to force an implicit merge
      out, err = capture_io do
        gu.pull("../Temp/Project")
      end
      assert_equal "Merge Conflict \nBool.hs has modification conflict \n3b7e...c827 => 4116...931b\n3b7e...c827 => a0fe...8cc6\nCould not be resolved \n\nWhale.hs has addition conflict \nadd => ff0e...0c87\nadd => 02d0...2714\nCould not be resolved \n\n", out
      
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
  