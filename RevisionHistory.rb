require_relative "RevisionNode.rb"
class RevisionHistory
    def initialize()
        @head = nil
        @temp = nil
        @hashCount = {}
    end

    def addFile(path)
        if @temp.nil?
            @temp = RevisionNode.new()
        end

        # Get hash of a file
        hash = "advef"
        h = @temp.addFile(path, hash)

        if @hashCount[hash].nil?
            @hashCount[hash] = 1
        # use file system module to copy file
        else
            @hashCount[hash] += 1
        end
    end

    def removeFile(path)
        
    end

    def commit()
        if @temp.nil?
            puts "Nothing to commit"
            return 1
        end
    end
end

rh = RevisionHistory.new()
rh.addFile("a.txt")
