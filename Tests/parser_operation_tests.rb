require "minitest/autorun"
require 'minitest/stub_any_instance'
require "open3"
#require "Operation"
require_relative "../operation_module.rb"
require_relative "../parser_module.rb"
#load "../parser_module.rb"




#require_relative "t.rb"

#ARGV = ["this", "is", "a", "phrase"]
#load("t.rb")
class Test_p1 < Minitest::Test
  def setup
    
  end
  def test_init
    #successful_init
    Operation.stub_any_instance(:Operation_init, 1) do
      cmds = ["clone", ""]
      output, status = Open3.capture2("ruby ../parser_module.rb init")
      assert_equal
    end
    #fail_init
    #Operation.stub :Operation.Operation_init, 1 do
    #  puts "test"
    #end 
  end
end
output, status = Open3.capture2("ruby t.rb something")
puts("Program Ran")
puts("output is #{output}")