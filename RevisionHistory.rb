require_relative "RevisionNode.rb"
require_relative "file_system.rb"

# TODO:
# 1. hashCount does not fully functional. The repo may contain unnecessary files.
class RevisionHistory
    def initialize(path, init)
        @PATH_PREFIX = "./dvcs/"

        @currPath = path
        if init
            FileSystem.init()
            @head = nil
            @temp = nil
            @hashCount = {}
            @count = 0
        else
            # load from disk
            test2Rh(FileSystem.get_rh())

        end
    end

    def text2Rh(text)

    end

    def rh2Text()

    end

    def addFile(path)
        if @temp.nil?
            @temp = RevisionNode.new()
            if !@head.nil?
                @temp.setFileHash(@head.getFileHash.clone)
            end
        end

        # Get hash of a file
        hash = FileSystem.getHash(path)
        h = @temp.addFile(path, hash)

        if @hashCount[hash].nil?
            @hashCount[hash] = 1
            FileSystem.cpy(path, @PATH_PREFIX + hash.to_s)
        else
            @hashCount[hash] += 1
        end
    end

    def removeFile(path)
        
    end

    def calcHash(node)
        @count += 1
        return @count
    end

    def commit()
        if @temp.nil? || @temp.getState == RevisionState::INITIALIZED
            puts "No changes added to commit"
            return -1
        end

        @temp.setCommidId(calcHash(@temp))
        @head.setNext(@temp)
        @temp.setPrev(@head)
        @temp.setState(RevisionState::COMMITED)
        @head = @temp
        @temp = nil
        return 0
    end

    def to_s()
        
    end
end

if __FILE__ == $0
    rh = RevisionHistory.new()
    rh.addFile("a.txt")
    puts rh.hashCount
end
