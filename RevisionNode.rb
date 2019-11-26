# coding: utf-8
module RevisionState
    INITIALIZED = 1
    MODIFIED = 2
    COMMITED = 3
end

class RevisionNode
    def initialize()
        @commitId = 0
        @commitMsg = ""
        @fileHash = {}
        @state = RevisionState::INITIALIZED
        @prev = nil
        @next = nil
    end

    def setCommitId(id)
        @commitId = id
    end

    def setCommitMsg(msg)
        @commitMsg = msg
    end

    def setState(state)
        @state = state
    end

    def setFileHash(fileHash)
        @fileHash = fileHash
    end

    def setNext(node)
        @next = node
    end

    def setPrev(node)
        @prev = node
    end

    def getNext()
        @next
    end

    def getState()
        @state
    end

    def getFileHash()
        @fileHash
    end

    def getCommitId()
        @commitId
    end

    def getCommitMsg()
        @commitMsg
    end

    def deleteFile(path)
        # check if the hash(path) appears in parent nodes
        # if not, delete from metadata
        # maybe need a counter for each hash file
        if @fileHash[path].nil?
            raise "File " + path + " is not under version control."
        end
        @fileHash.delete(path)
        return 0
    end

    def addFile(path, hash)
        if @fileHash[path] == hash
            puts "Added the same file " + path
            return 1
        end
        @fileHash[path] = hash
        return 0
    end

    def each(&block)
        block.call(self)
        self.getNext.each(&block) if self.getNext
    end

    def to_s
        "CommitID: #{@commitId}\nCommit Message: #{@commitMsg}\nFile Hash: #{@fileHash}\n\n"        
    end

    def print
        if @next.nil?
            self.to_s
        else
            self.to_s + @next.print
        end
    end

end
