require_relative 'RevisionHistory.rb'

module GeneralUtility

	def get_repo(path)
		if Dir.exist?(path)
			return RevisionHistory.new(path, false)
		else
			raise 'target directory does not exist'
			return nil
		end
	end

	def lca(rh_s, rh_t)
		tree_s = rh_s.temp
		tree_t = rh_t.temp
		if (tree_s.commitID == tree_t.commitID)
			identical_node = nil
			while (tree_s != nil && tree_t != nil)
				if (tree_s.commitID == tree_t.commitID)
					identical_node = tree_s
				end
				tree_s = tree_s.next
				tree_t = tree_t.next
			end
			return identical_node
		else
			raise 'rh1 and rh2 are different repositories'
			return nil
		end
	end

	def merge(rh_s, rh_t, common)
		if (common_node.commitID = rh_t.head.commitID)
			rh_t.head.next = common_node.next
			rh_t.head = rh_s.head
			# tracked hash file copy
			# store modified revision tree to filesystem
			return 1
		else
			#resolve merge conflict
			return -1
		end
	end

	def push(target_dir)
		working_dir = Dir.pwd
		target_repo = get_repo(target_dir)
		working_repo = get_repo(working_dir)
		if (target_repo.head == nil)
			raise 'target directory is not a repository or corrupted'
		elsif (working_repo.head == nil)
			raise 'working directory is not a repository or corrupted'
		else
			common_node = lca(working_repo, target_repo)
			if (merge(working_repo, target_repo, common_node) < 0)
				raise 'merge failed'
			end
		end
	end

	def pull(remote_dir)
		working_dir = Dir.pwd
		remote_repo = get_repo(remote_dir)
		working_repo = get_repo(working_dir)
		if (remote_repo.head == nil)
			raise 'remote directory is not a repository or corrupted'
		elsif (working_repo.head == nil)
			raise 'working directory is not a repository or corrupted'
		else
			common_node = lca(remote_repo, working_repo)
			if (merge(remote_repo, working_repo, common_node) < 0)
				raise 'merge failed'
			end
		end
	end

end