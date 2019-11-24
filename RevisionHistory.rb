require_relative "RevisionNode"
require_relative "file_system"

# TODO:
# 1. hashCount does not fully functional. The repo may contain unnecessary files.
class RevisionHistory
include FileSystem

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
            text2Rh(FileSystem.get_rh())

        end
    end

    def getHashCount()
        return @hashCount
    end

    def text2Rh(text)
            @head = nil
            @temp = nil
            @hashCount = {}
            @count = 0
    end

    def rh2Text()
        return "asd"
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
        puts hash
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

    def setCommitMsg(msg)
        if @temp.nil? || @temp.getState == RevisionState::INITIALIZED
            puts "No changes added to commit"
            return -1
        end
        @temp.setCommitMsg(msg)
    end

    def commit()
        if @temp.nil? || @temp.getState == RevisionState::INITIALIZED
            puts "No changes added to commit"
            return [-1, nil]
        end

        commitId = calcHash(@temp)
        @temp.setCommitId(commitId)
        if !@head.nil?
            @head.setNext(@temp)
            @temp.setPrev(@head)
        end
        @temp.setState(RevisionState::COMMITED)
        @head = @temp
        @temp = nil
        return [commitId, @head.getCommitMsg]
    end

    def print
        if @head.nil?
            puts "Revision history is empty."
        else
            @head.each{|x| x.print}
        end
    end
end

if __FILE__ == $0
    rh = RevisionHistory.new(Dir.pwd, false)
    rh.addFile("a.txt")
    rh.setCommitMsg("commit msg")
    rh.commit()
    rh.print
    puts rh.getHashCount
end
