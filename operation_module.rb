require_relative 'file_system.rb'
require_relative 'RevisionHistory.rb'
require_relative 'general_utility.rb'

module Operation
    include FileSystem
    include GeneralUtility
    def Operation_init()
        begin
        rh=RevisionHistory.new(Dir.pwd, true)
        rh.rh2Text()
        return 0;
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

    def Operation_add(pth)
        rh=RevisionHistory.new(Dir.pwd, false)
        begin
            result=rh.add(pth)
            rh.rh2Text()
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
        rh=RevisionHistory.new(Dir.pwd, false)
        begin
            if rh.delete(pth)>=0
                rh.rh2Text()
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
        rh=RevisionHistory.new(Dir.pwd, false)
        begin
            puts rh.status()
            rh.rh2Text()
            return 0;
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_heads()
        rh=RevisionHistory.new(Dir.pwd, false)
        begin
            l= rh.heads();
            rh.rh2Text()
            puts "commit id is %s" % [l[0]]
            puts "commit message is %s" % [l[1]]
            return 0;
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_diff(rev1,rev2)
        rh=RevisionHistory.new(Dir.pwd, false)
        begin
            l=rh.diff(rev1,rev2);
            rh.rh2Text()
            puts l
            return 0;
        rescue StandardError => e
            puts e.message
            return 1;
        end
    end

    def Operation_cat(pth,rev_num)
        rh=RevisionHistory.new(Dir.pwd, false)
        begin
            file=rh.getFile(pth,rev_num)
            rh.rh2Text()
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
        rh=RevisionHistory.new(Dir.pwd, false)
        begin
            result=rh.checkout(commitid)
            rh.rh2Text()
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

    def Operation_commit(commit_mes)
        rh=RevisionHistory.new(Dir.pwd, false)
        rh.setCommitMsg(commit_mes)
        begin
            com=rh.commit()
            puts "commit id is %s" % [com[0]]
            puts "commit message is %s" % [com[1]]
            result=com[0]
            rh.rh2Text()
            if result.length>=0
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
        rh=RevisionHistory.new(Dir.pwd, false)
        begin
            puts rh.log()
            rh.rh2Text()
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
