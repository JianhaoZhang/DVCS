require "minitest/autorun"
require "open3"
require 'digest/sha1'
require_relative "../RevisionHistory.rb"
#@@root = "../parser_module.rb"
class Test_p1 < Minitest::Test
  @@root = "../../parser_module.rb"
  def setup
    if Dir.exist?("Project")
      system("rm -r Project")
    end
    system("mkdir Project\nmkdir Temp\n cd Project \n touch new.txt\n")
  end
  
  def test_gen
    skip
    Dir.chdir("Project") do
      #test init
      system("ruby #{@@root} init")
      
      assert Dir.exist?(".dvcs")
      assert File.exist?(".dvcs/revision_history_file")
      
      #test commit
      File.open("a.txt", "w"){|f| f.write("1 2 3 4 5")}
      system("ruby #{@@root} add a.txt")
      system("ruby #{@@root} commit 'added a.txt'")
      #hash = Digest::SHA1.hexdigest "a.txt"
      
      #test status
      output, status = Open3.capture2("ruby #{@@root} status")
      
      assert_equal output.to_a(), ["Added file:\na.txt"]
      
      #test edit commit and status
      File.open("a.txt", "w"){|f| f.write("6 7 8 9 10")}
      system("ruby #{@@root} commit 'edited a.txt'")
      
      assert_equal output.to_a(), ["Edited file:\na.txt"]
      
      #test remove and status
      system("ruby #{@@root} remove a.txt")
      system("ruby #{@@root} commit 'removed a.txt'")
      
      output, status = Open3.capture2("ruby #{@@root} status")
      
      assert_equal output.to_a(), ["Removed file:\na.txt"]
      
      system("ruby #{@@root} add a.txt")
      system("ruby #{@@root} commit 'added a.txt'")
      
      #display logs
      output, status = Open3.capture2("ruby #{@@root} heads")
      
      puts output
      
      #display heads data
      output, status = Open3.capture2("ruby #{@@root} log")
      
      puts log
      
      #to be updated once methods are finished, undecided how to calculate the revision numbers and commit id values
      a = 0, b = 1
      
      #diff between them should be 0 (taking two identical files)
      output, status = Open3.capture2("ruby #{@@root} diff #{a} #{b}")
      assert_equal output, [""]
      
      #should dump contents of file
      #again revision number to be calculated
      output, status = Open3.capture2("ruby #{@@root} cat a.txt #{a}")
      assert_equal output, output ["6 7 8 9 10"]
      
      #revert to point when a.txt wasn't in the project
      system("ruby #{@@root} checkout #{a}")
      assert !File.exist?("a.txt")
      
    end 
    
    
  end
  
  def test_other
    
    #Dir.chdir("Project") do
      #basic init stuff
    #  system("ruby #{@@root} init")
      
    #  output, status = Open3.capture2("ruby #{@@root} init")
      
    #  File.open("a.txt", "w"){|f| f.write("1 2 3 4 5")}
    #  system("ruby #{@@root} add a.txt")
      
    #  system("ruby #{@@root} commit 'added a.txt'")
    #end
    
    #bypass parser_init
    Dir.chdir("Project") do
      RevisionHistory.new(Dir.pwd, true)
      assert_equal "Revision history is empty.", rh.log()
            
    end
    
    
    Dir.chdir("Temp") do
      
      #clone test
      system("ruby #{@@root} clone ../Project")
      
      #clone shoudl be copy of original
      output, status = Open3.capture2("diff Project ../Project")
      assert output.empty?
      
      Dir.chdir("Project") do
        #create new file
        File.open("b.txt", "w"){|f| f.write("asdfg")}
        system("ruby ../#{@@root} add b.txt")
        system("ruby ../#{@@root} commit 'added b.txt")
        
        #since @@root project hasn't changed, pulling will do nothing
        system("ruby ../#{@@root} pull ../../Project")
        output, status = Open3.capture2("ruby ../#{@@root} status")
        assert_equal output, ["No changes in current repository"]
        
        system("ruby ../#{@@root} push ../../Project")
        
      end
      
    end
    
    Dir.chdir("Project") do
      #after pushing, b.txt should now exist
      assert File.exist?("b.txt")
      
      
    end
    
  end
  
  def test_merge
    skip
    Dir.chdir("Project") do
      #basic init stuff
      system("ruby #{@@root} init")
      
      output, status = Open3.capture2("ruby #{@@root} init")
      
      File.open("a.txt", "w"){|f| f.write("1 2 3 4 5")}
      system("ruby #{@@root} add a.txt")
      
      system("ruby #{@@root} commit 'added a.txt'")
    end
    
    Dir.chdir("Temp") do
      #clone 
      system("ruby ../#{@@root} clone ../Project")
      File.open("b.txt", "w"){|f| f.write("asdf")}
      system("ruby ../#{@@root} add b.txt")
      
      system("ruby ../#{@@root} commit 'added b.txt'")
    end
    
    Dir.chdir("Project") do
      File.open("a.txt", "w"){|f| f.write("1 2 3 4 5 6 7 8 9 10")}
      system("ruby #{@@root} commit 'modified a.txt'")
      
      #both projects have been edited so this pull will force a merge
      system("ruby #{@@root} pull ../Temp/Project")
      
      #look at the status to see what the merge caused
      system("ruby #{@@root} status")
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