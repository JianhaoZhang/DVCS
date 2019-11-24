require 'Operation'
module Parser

def parse(*args):
	case args[1]
		when "init"
			return Operation_init();
		when "clone"
			return Operation_clone(args[2]);
		when "add"
			return Operation_add(args[2]);
		when "remove"
			return Operation_remove(args[2]);
		when "status"
			Operation_status()
			return 0;
		when "heads"
			return Operation_heads(args[2])[0].to_i;
		when "diff"
			Operation_diff(args[2],args[3])
			return 1;
		when "cat"
			Operation_cat(args[2],args[3])
			return 1;
		when "checkout"
			return Operation_checkout(args[2]);
        when "commit"
        	return Operation_commit(args[2])[0].to_i;
        when "log"
        	Operation_log()
        	return 1;
        when "pull"
            return Operation_pull(args[2]);
        when "push"
        	return Operation_push(args[2]);
    end
end