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
					identical_node = tree_t
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

	def merge(rh_s, rh_t)
		
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
		end
	end

end