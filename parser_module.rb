require_relative 'operation_module.rb'
require_relative 'RevisionHistory.rb'
module Parser
include Operation
def prompt(sig)
    if sig==0
        puts "command succeeds"
    else
        puts "command fails"
    end
end

def parse(args,rh)
    case args[0]
        when "init"
            prompt(Operation_init())
        when "clone"
            prompt(Operation_clone(args[1]))
        when "add"
            prompt(Operation_add(args[1],rh))
        when "remove"
            prompt(Operation_remove(args[1]))
        when "status"
            prompt(Operation_status(rh))
        when "heads"
            prompt(Operation_heads(rh))
        when "diff"
            prompt(Operation_diff(args[1],args[2]))
        when "cat"
            prompt(Operation_cat(args[1],args[2],rh))
        when "checkout"
            prompt(Operation_checkout(args[1],rh))
        when "commit"
            prompt(Operation_commit(args[1],rh)[0])
        when "log"
            prompt(Operation_log(rh))
        when "pull"
            prompt(Operation_pull(args[1]))
        when "push"
            prompt(Operation_push(args[1]))
        when "exit"
            puts "Successfully end the program"
            exit
    end
end
end
class Mymain
    include Parser
end

m=Mymain.new()
rh=RevisionHistory.new(Dir.pwd, false)
while 1
puts "Enter your command:\n"
command=gets.chomp
args=command.split()
m.parse(args,rh)
end
