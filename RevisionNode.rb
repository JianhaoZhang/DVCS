# coding: utf-8
module RevisionState
    INITIALIZED = 1
    MODIFIED = 2
    COMMITED = 3
end

class RevisionNode
    attr_accessor :prev
    attr_accessor :next
    attr_accessor :state
    attr_accessor :fileHash
    attr_accessor :commitId
    attr_accessor :commitMsg
    attr_accessor :time
    attr_reader :prev
    attr_reader :next
    attr_reader :state
    attr_reader :fileHash
    attr_reader :commitId
    attr_reader :commitMsg
    attr_reader :time

    def initialize()
        @commitId = 0
        @commitMsg = ""
        @fileHash = {}
        @state = RevisionState::INITIALIZED
        @prev = nil
        @next = nil
        @time = nil
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
        self.next.each(&block) if self.next
    end

    def to_s
        "CommitID: #{@commitId}\nTime: #{@time}\nCommit Message: #{@commitMsg}\nFile Hash: #{@fileHash}\n\n"
    end

    def print
        if @next.nil?
            self.to_s
        else
            self.to_s + @next.print
        end
    end

end
