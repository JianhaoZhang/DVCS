require_relative "RevisionNode"
require_relative "file_system"

# TODO:
# 1. hashCount does not fully functional. The repo may contain unnecessary files.
class RevisionHistory
    include FileSystem

    def initialize(path, init)
        @PATH_PREFIX = "/.dvcs/"

        @currPath = path
        if init
            FileSystem.init()
            @head = nil
            @tail = nil
            @temp = nil
            @hashCount = {}
            @commitMap = {}
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
        @tail = nil
        @temp = nil
        @hashCount = {}
        @commitMap = {}
        @count = 0
    end

    def rh2Text()
        if !self.head.nil?
            str = self.log
            FileSystem.store_rh(str)
        end
    end

    def addFile(path)
        if @temp.nil?
            @temp = RevisionNode.new()
            if !@tail.nil?
                @temp.setFileHash(@tail.getFileHash.clone)
            end
        end

        # Get hash of a file
        hash = FileSystem.getHash(path)
        puts hash
        h = @temp.addFile(path, hash)

        if @hashCount[hash].nil?
            @hashCount[hash] = 1
            FileSystem.cpy(@currPath + path, @currPath + @PATH_PREFIX + hash)
        else
            @hashCount[hash] += 1
        end
        if @tail.nil? || @tail.getFileHash != @temp.getFileHash
            @temp.setState(RevisionState::MODIFIED)
        else
            @temp.setState(RevisionState::INITIALIZED)
        end

    end

    def removeFile(path)
        if @temp.nil?
            @temp = RevisionNode.new()
            if !@head.nil?
                @temp.setFileHash(@tail.getFileHash.clone)
            end
        end
        @temp.deleteFile(path)
        if @tail.nil? || @tail.getFileHash != @temp.getFileHash
            @temp.setState(RevisionState::MODIFIED)
        else
            @temp.setState(RevisionState::INITIALIZED)
        end
    end

    def diff(commitId1, commitId2)
        if @commitMap[commitId1].nil?
            raise "Invalid CommitID " + commitId1
        end
        if @commitMap[commitId2].nil?
            raise "Invalid CommitID " + commitId2
        end

        fileHash1 = @commitMap[commitId1].getFileHash
        fileHash2 = @commitMap[commitId2].getFileHash
        ret = fileHash1.map do |pth, hash|
            if fileHash2[pth].nil?
                ["---- Delete file " + pth + "\n"] + FileSystem.read(@currPath + @PATH_PREFIX + hash)
            elif fileHash1[pth] != fileHash2[pth]
                ["+-+- Change file " + pth + "\n"] + FileSystem.diff(@currPath + @PATH_PREFIX + hash, @currPath + @PATH_PREFIX + fileHash2[pth])
            end
        end
        ret += fileHash2.map do |pth, hash|
            if fileHash1[pth].nil?
                ["++++ Add file " + pth + "\n"] + FileSystem.read(@currPath + @PATH_PREFIX + hash)
            end
        end
        return ret
    end

    def getFile(path, commitId)
        node = @commitMap[commitId]
        if node.nil?
            raise "Commit " + commitId + " cannot be found."
        end
        
        if node.getFileHash[path].nil?
            raise "File " + path + "is not under version control for commit " + commitId + "."
        end

        return FileSystem.read(@currPath + @PATH_PREFIX + node.getFileHash[path])
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
        @commitMap[commitId] = @temp
        if !@tail.nil?
            @tail.setNext(@temp)
            @temp.setPrev(@tail)
        else
            @head = @temp
        end
        @temp.setState(RevisionState::COMMITED)
        @tail = @temp
        @temp = nil
        return [commitId, @tail.getCommitMsg]
    end

    def heads
        if @tail.nil?
            raise "The repository is empty."
        end
        return [@tail.getCommitId, @tail.getCommitMsg]
    end

    def log
        if @head.nil?
            return "Revision history is empty."
        else
            return @head.print
        end
    end

    def checkout(commitId)
        if @commitMap[commitId].nil?
            raise "Invalid CommitID " + commitId
        end
        fileHash = @@commitMap[commitId].getFileHash
        fileHash.each {|pth, hash| FileSystem.cpy(@currPath + @PATH_PREFIX + hash, @currPath + pth)}
        return 0
    end

    def status

    end
end

if __FILE__ == $0
    rh = RevisionHistory.new(Dir.pwd, false)
    rh.addFile("./a.txt")
    rh.setCommitMsg("Add a.txt")
    rh.commit()

    rh.addFile("./b.txt")
    rh.setCommitMsg("Add b.txt")
    rh.commit()

    rh.removeFile("./b.txt")
    rh.setCommitMsg("Remove b.txt")
    rh.commit()

    puts rh.diff(1, 2)
    puts rh.getFile("./b.txt", 2)
    puts rh.log
    # puts rh.heads
    # rh.print
    # puts rh.getHashCount
end
