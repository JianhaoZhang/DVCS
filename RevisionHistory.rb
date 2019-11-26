require_relative "RevisionNode"
require_relative "file_system"

# TODO:
# 1. hashCount does not fully functional. The repo may contain unnecessary files.
class RevisionHistory
    include FileSystem

    def initialize(path, init)
        @PATH_PREFIX = "/.dvcs/"

        @currPath = path

        @head = nil
        @tail = nil
        @temp = nil
        @hashCount = {}
        @commitMap = {}
        @count = 0
        if init
            FileSystem.init()
        else
            # load from disk
            text2Rh()

        end
    end

    def getHashCount()
        return @hashCount
    end

    def text2Rh()
        text = FileSystem.get_rh()
        @temp = nil
        text.each_with_index do |e, idx|
            if e.start_with?("CommitID:")
                @count+=1
                if !@temp.nil?
                    @commitMap[@temp.getCommitId()] = @temp
                    if !@tail.nil?
                        @tail.setNext(@temp)
                        @temp.setPrev(@tail)
                    else
                        @head = @temp
                    end
                    @temp.setState(RevisionState::COMMITED)
                    @tail = @temp   
                end 
                @temp = RevisionNode.new()
                @temp.setCommitId(e.split(":")[1].strip.to_i)
            elsif e.start_with?("Commit Message:")
                @temp.setCommitMsg(e.split(":")[-1][1..-1])
            elsif e.start_with?("File Hash:")
                e_dict = eval(e.split(":")[-1][1..-1])
                e_dict.each do |key, value|
                    @temp.addFile(key, value)
                    if @hashCount[value].nil?
                        @hashCount[value] = 1
                    else
                        @hashCount[value] += 1
                    end
                end
            end
        end
        
        if !@temp.nil?
            @commitMap[@temp.getCommitId()] = @temp
            if !@tail.nil?
                @tail.setNext(@temp)
                @temp.setPrev(@tail)
            else
                @head = @temp
            end
            @temp.setState(RevisionState::COMMITED)
            @tail = @temp   
        end 
        @temp = nil
    end

    def rh2Text()
        if !self.heads.nil?
            str = self.log
            FileSystem.store_rh(str)
        end
    end

    def add(path)
        if @temp.nil?
            @temp = RevisionNode.new()
            if !@tail.nil?
                @temp.setFileHash(@tail.getFileHash.clone)
            end
        end

        # Get hash of a file
        hash = FileSystem.getHash(path)
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
        return 0
    end

    def delete(path)
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
        return 0
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
            elsif fileHash1[pth] != fileHash2[pth]
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
        if @temp.nil? || @temp.getState == RevisionState::INITIALIZED
            return "No changes in current repository"
        elsif @tail.nil?
            "Added file:\n" + @temp.getFileHash.collect {|pth, hash| pth}
        else
            fileHash1 = @tail.getFileHash
            fileHash2 = @temp.getFileHash
            modified = []
            deleted = []
            added = []
            fileHash1.each do |pth, hash|
                if fileHash2[pth].nil?
                    deleted << pth
                elsif fileHash1[pth] != fileHash2[pth]
                    changed << pth
                end
            end
            fileHash2.each do |pth, hash|
                if fileHash1[pth].nil?
                    added << pth
                end
            end
            ret = ""
            if added.length != 0
                ret += "Added file(s):\n" + added.to_s
            end
            if deleted.length != 0
                ret += "\nDeleted file(s):\n" + deleted.to_s
            end
            if modified.length != 0
                ret += "\nModified file(s):\n" + modified.to_s
            end
            return ret
        end
    end
end

if __FILE__ == $0
    rh = RevisionHistory.new(Dir.pwd, false)
    # rh.addFile("./a.txt")
    # rh.setCommitMsg("Add a.txt")
    # rh.commit()
    puts rh.log

    # rh.addFile("./b.txt")
    # # puts rh.status
    # rh.setCommitMsg("Add b.txt")
    # rh.commit()

    # rh.removeFile("./b.txt")
    # rh.setCommitMsg("Remove b.txt")
    # rh.commit()

    # # # puts rh.diff(1, 2)
    # # # # puts rh.getFile("./b.txt", 2)
    # # puts '--------------'
    # rh.rh2Text()
    # rh.text2Rh()
end
