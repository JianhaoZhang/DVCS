require_relative 'operation_module.rb'
module Parser

def prompt(sig)
    if sig==0
        puts "command succeeds"
    else
        puts "command fails"
    end
end

def parse(args)
    case args[0]
        when "init"
            prompt(Operation_init())
        when "clone"
            prompt(Operation_clone(args[1]))
        when "add"
            prompt(Operation_add(args[1]))
        when "remove"
            prompt(Operation_remove(args[1]))
        when "status"
            prompt(Operation_status())
        when "heads"
            prompt(Operation_heads(args[1])[0])
        when "diff"
            prompt(Operation_diff(args[1],args[2]))
        when "cat"
            prompt(Operation_cat(args[1],args[2]))
        when "checkout"
            prompt(Operation_checkout(args[1]))
        when "commit"
            prompt(Operation_commit(args[1])[0])
        when "log"
            prompt(Operation_log())
        when "pull"
            prompt(Operation_pull(args[1]))
        when "push"
            prompt(Operation_push(args[1]))
    end
end
end
class Mymain
    include Parser
end

m=Mymain.new()
m.parse(ARGV)
