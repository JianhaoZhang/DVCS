require 'File_System'
require 'Revision_History'
require 'General_Utility'

module Operation
    def Operation_init()
        if init_repository()==1 and init_rh()==1:
            return 1;
        else:
            return 0;
     end
    end

    def Operation_clone(pth):
        return clone(pth);
    end

    def Operation_add(pth):
        return add(pth);
    end

    def Operation_remove(pth):
        return delete(pth);
    end

    def Operation_status();
        return status();
    end

    def Operation_heads();
        return heads();
    end

    def Operation_diff(rev1,rev2):
        l=diff(rev1,rev2);
        p l
        return l;
    end

    def Operation_cat(pth,rev_num):
        return cat(pth,rev_num);
    end

    def Operation_checkout(commitid):
        return checkout(commitid);
    end

    def Operation_commit(commit_mes):
        return commit(commit_mes);
    end

    def Operation_log():
        return log();
    end

    def Operation_pull(url):
        return pull(url);
    end

    def Operation_push(url):
        return push(url);
    end

end
