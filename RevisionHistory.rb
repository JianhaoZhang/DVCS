require_relative "RevisionNode.rb"
class RevisionHistory
    def initialize()
        @head = nil
        @temp = nil
        @hashCount = {}
        @count = 0
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

    def calcHash(@temp)
        @count += 1
        return @count
    end

    def commit()
        if @temp.nil? || @temp.getState == RevisionState::INITIALIZED
            puts "Work tree is clean. Nothing to commit"
            return 1
        end

        @temp.setCommidId(calcHash(@temp))
        @head.setNext(@temp)
        @temp.setPrev(@head)
        @temp.setState(RevisionState::COMMITED)
        @head = @temp
        return 0
    end

    def to_s()
        
    end
end

rh = RevisionHistory.new()
rh.addFile("a.txt")
puts rh.hashCount
