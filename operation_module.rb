require 'File_System'
require 'Revision_History'
require 'General_Utility'

module Operation
    def Operation_init()
        begin
            if init_repository()>=0 and init_rh()>=0
                return 0;
            else
                return 1;
            end
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_clone(pth)
        begin
            if clone(pth)>=0
                return 0;
            else
                return 1;
            end
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_add(pth)
        begin
            if add(pth)>=0
                return 0;
            else
                return 1;
            end
        rescue StandardError => e
            puts e.message
            return 1;
        end        
    end

    def Operation_remove(pth)
        begin
            if delete(pth)>=0
                return 0;
            else
                return 1;
            end
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_status()
        begin
            p status()
            return 0;
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_heads()
        begin
            l= heads();
            puts "commit id is %s" % [l[0]]
            puts "commit message is %s" % [l[1]]
            return 0;
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_diff(rev1,rev2)
        begin
            l=diff(rev1,rev2);
            p l
            return 0;
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_cat(pth,rev_num)
        begin
            file=getFile(pth,rev_num)
            file.each_line do |line|
                puts line
            end
            return 0;
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_checkout(commitid)
        begin
            if checkout(commitid)>=0
                return 0;
            else
                return 1;
            end
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_commit(commit_mes)
        begin
            if commit(commit_mes)>=0
                return 0;
            else
                return 1;
            end
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_log()
        begin
            p log()
            return 0;
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_pull(url)
        begin
            if pull(url)>=0
                return 0;
            else
                return 1;
            end
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_push(url)
        begin
            if push(url)>=0
                return 0;
            else
                return 1;
            end
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

end
