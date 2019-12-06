require_relative 'file_system.rb'
require_relative 'RevisionHistory.rb'
require_relative 'general_utility.rb'

module Operation
    include FileSystem
    include GeneralUtility
    def Operation_init()
        begin
            if FileSystem.init()>=0
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
            if FileSystem.clone(pth)>=0
                return 0;
            else
                return 1;
            end
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_add(pth,rh)
        begin
            result=rh.add(pth)
            if result>=0
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
            if FileSystem.delete(pth)>=0
                return 0;
            else
                return 1;
            end
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_status(rh)
        begin
            p rh.status()
            return 0;
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_heads(rh)
        begin
            l= rh.heads();
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
            l=FileSystem.diff(rev1,rev2);
            p l
            return 0;
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_cat(pth,rev_num,rh)
        begin
            file=rh.getFile(pth,rev_num)
            file.each_line do |line|
                puts line
            end
            return 0;
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_checkout(commitid,rh)
        begin
            result=rh.checkout(commitid)
            if result>=0
                return 0;
            else
                return 1;
            end
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_commit(commit_mes,rh)
        rh.setCommitMsg(commit_mes)
        begin
            result=rh.commit()[0]
            if result>=0
                return 0;
            else
                return 1;
            end
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_log(rh)
        begin
            p rh.log()
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
