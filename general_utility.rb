require_relative 'RevisionHistory.rb'
require_relative 'RevisionNode.rb'
require_relative 'file_system.rb'

$repo_folder = '/.dvcs/'

module GeneralUtility

	def get_repo(path)
		if Dir.exist?(path)
			rh = RevisionHistory.new(path, false)
			return rh
		else
			raise 'target directory does not exist'
		end
	end

	def lca(rh_s, rh_t)
		tree_s = rh_s.head
		tree_t = rh_t.head
		if (tree_s.getCommitId() == tree_t.getCommitId())
			identical_node = nil
			while (tree_s != nil && tree_t != nil)
				if (tree_s.getCommitId() == tree_t.getCommitId())
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

	def write_back_list(hash_invert, hashcodes)
		result = []
		for h in hashcodes
			result << hash_invert[h]
		end
		return result
	end

	def list_files(path)
		return Dir.entries(path).select {|f| !File.directory? f}
	end

	def merge(rh_s, rh_t, common)
		if (common.next != nil && common.getCommitId() == rh_t.tail.getCommitId())
			#fast-forward merge
			rh_t.tail.next = common.next
			rh_t.tail.next.prev = rh_t.tail
			

			while (rh_t.tail.next != nil)
				rh_t.tail = rh_t.tail.next
			end

			src_file_list = list_files(rh_s.currPath + $repo_folder)
			target_file_list = list_files(rh_t.currPath + $repo_folder)

			if src_file_list.include?('revision_history_file') && target_file_list.include?('revision_history_file')
				file_list = src_file_list - target_file_list
				file_list.each{|f| FileSystem.cpy(rh_s.currPath + $repo_folder + f, rh_t.currPath + $repo_folder)}
				#wbl = write_back_list(rh_s.getFileHash)
			else
				raise 'source or target revision history is corrupted'
			end

			rh_t.rh2Text()

			return 1
		elsif (common.next == nil && common.getCommitId() == rh_t.tail.getCommitId())
			puts 'Repositories are identical, no need to push/pull'
			return 0
		else
			#3-way merge
			cursor = rh_t.tail
			while (cursor.getCommitId() != common.getCommitId())
				cursor = cursor.prev
			end

			lca_hashes = common.getFileHash().to_a
			src_hashes = rh_s.tail.getFileHash().to_a
			target_hashes = rh_t.tail.getFileHash().to_a

			src_changes = src_hashes - lca_hashes
			src_deletions = (lca_hashes - src_hashes) - src_changes
			tgt_changes = target_hashes - lca_hashes
			tgt_deletions = (lca_hashes - target_hashes) - tgt_changes

			src_temp = split_add_mod(src_changes)
			src_modifications = src_temp[0]
			src_additions = src_temp[1]

			tgt_temp = split_add_mod(tgt_changes)
			tgt_modifications = tgt_temp[0]
			tgt_additions = tgt_temp[1]

			all_deletions = []
			for deletion in (src_deletions + tgt_deletions)
				all_deletions << deletion[0]
			end

			merge_conflicts = []

			for mod_s in src_modifications
				for mod_t in tgt_modifications
					if mod_s[0] == mod_t[0]
						if mod_s[1] == mod_t[1]
							if mod_s[2] != mod_t[2]
								merge_conflicts << [mod_s[0], mod_s[1], mod_s[2], mod_t[2]]
							end
						else
							raise 'fatal logic problem with common ancestor'
						end
					end
				end
			end

			for add_s in src_additions
				for add_t in tgt_additions
					if add_s[0] == add_t[0]
						if add_s[1] != add_t[1]
							merge_conflicts << [add_s[0], 'addition', add_s[1], add_t[1]]
						else
						end
					end
				end
			end

			merge_conflicts = merge_conflicts.uniq

			for i in merge_conflicts
				puts i
			end

			if merge_conflicts != nil
				answered = false
				while (!answered)
					puts 'Merge conflict happens, merge forcibly? (Y/N)'
					input = gets
					if (input.strip.downcase == 'y')
						answered = true
						puts 'not supported yet, merge terminated'
					elsif (input.strip.downcase == 'n')
						answered = true
						puts 'merge terminated by user'
					else
						puts 'input not recognized, merge terminated'
					end
				end
			else
				merge_node = RevisionNode.new()
				merge_node = common
				common_file_hash = merge_node.getFileHash()
				h_add_s = Hash[*src_additions.flatten]
				h_add_t = Hash[*tgt_additions.flatten]
				h_mod_s = Hash[*retrieve_modification(src_modifications).flatten]
				h_mod_t = Hash[*retrieve_modification(tgt_modifications).flatten]
				common_file_hash.merge(h_add_s)
				common_file_hash.merge(h_add_t)
				common_file_hash.merge(h_mod_s)
				common_file_hash.merge(h_mod_t)
				for deletion in all_deletions
					common_file_hash.delete(deletion)
				end
				merge_node.setFileHash(common_file_hash)
				cur_id = merge_node.getCommidId() + 1
				merge_node.setCommitId(cur_id)
				merge_node.setCommitMsg('Merged ' + rh_s.currPath + ' to ' + rh_t.currPath)
				merge_node.setState(3)
				merge_node.next = nil
				while (rh_s.tail.prev != nil)
					if (rh_s.tail.getCommidId() == common.getCommidId())
						break
					end
					rh_s.tail = rh_s.tail.prev
				end
				while (rh_t.tail.prev != nil)
					if (rh_t.tail.getCommidId() == common.getCommidId())
						break
					end
					rh_t.tail = rh_t.tail.prev
				end
				rh_t.tail.next = merge_node
				rh_t.tail.next.prev = rh_t.tail
				rh_t.tail = rh_t.tail.next
				rh_s.tail.next = merge_node
				rh_s.tail.next.prev = rh_s.tail
				rh_s.tail = rh_s.tail.next

				src_file_list = list_files(rh_s.currPath + $repo_folder)
				target_file_list = list_files(rh_t.currPath + $repo_folder)

				if src_file_list.include?('revision_history_file') && target_file_list.include?('revision_history_file')
					file_list_s_t = src_file_list - target_file_list
					file_list_t_s = target_file_list - src_file_list
					file_list_s_t.each{|f| FileSystem.cpy(rh_s.currPath + $repo_folder + f, rh_t.currPath + $repo_folder)}
					file_list_t_s.each{|f| FileSystem.cpy(rh_t.currPath + $repo_folder + f, rh_s.currPath + $repo_folder)}
				else
					raise 'source or target revision history is corrupted'
				end

				rh_t.rh2Text()
				rh_s.rh2Text()

			end
			return 2
		end
	end

	def retrieve_modification(modifications)
		result = []
		for i in modifications
			result << [i[0], i[2]]
		end
		return result
	end

	def split_add_mod(changes)
		result = []
		modifications = []
		additions = []
		mod_ruler = Array.new(changes.length, false)
		for i in 0..changes.length
			anchor = changes[i][0]
			for j in (i+1)..changes.length
				if anchor == changes[j][0]
					modifications << [anchor, changes[i][1], changes[j][1]]
					mod_ruler[i] = true
					mod_ruler[j] = true
				end
			end
			if !mod_ruler[i]
				additions << anchor
			end
		end	
		result << modifications
		result << additions
		return result
	end

	def resolve(rh_s, rh_t, common)
		
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
			if common_node != nil
				if (merge(working_repo, target_repo, common_node) < 0)
					raise 'merge failed'
				end
			else
				raise 'target repository is irrelevant'
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
			if common_node != nil
				if (merge(remote_repo, working_repo, common_node) < 0)
					raise 'merge failed'
				end
			else
				raise 'remote repository is irrelevant'
			end
		end
	end

end