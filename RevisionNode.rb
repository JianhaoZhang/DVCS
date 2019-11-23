module RevisionState
    INITIALIZED = 1
    MODIFIED = 2
    COMMITED = 3
end

class RevisionNode
    def initialize()
        @commitID = 0
        @commitMsg = ""
        @fileHash = {}
        @state = RevisionState::INITIALIZED
        @prev = nil
        @next = nil
    end

    def setCommitId(id)
        @commitID = id
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

    def getState()
        @state
    end

    def getFileHash()
        @fileHash
    end

    def deleteFile(path)
        # check if the hash(path) appears in parent nodes
        # if not, delete from metadata
        # maybe need a counter for each hash file
        if @fileHash[path].nil?
            puts "File " + path + "is not under version control."
            return -1
        end
        @fileHash
    end

    def addFile(path, hash)
        if @fileHash[path] == hash
            # Same as prev, nothing to change
            return 1
        end
        @fileHash[path] = hash
    end

    def removeFile(path)
    end
end
