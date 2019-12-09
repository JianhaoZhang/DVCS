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
		if (tree_s.commitId == tree_t.commitId)
			identical_node = nil
			while (tree_s != nil && tree_t != nil)
				if (tree_s.commitId == tree_t.commitId)
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

	def get_additions(hash1, hash2)
		added = hash2.keys - hash1.keys
		return hash2.select {|k,v| added.include?(k)}.to_a
	end

	def get_modifications(hash1, hash2)
		h1 = hash1.to_a
		h2 = hash2.to_a
		modifications = []
		for i in 0..h1.length-1
			for j in 0..h2.length-1
				if h1[i][0] == h2[j][0] && h1[i][1] != h2[j][1]
					modifications << [h1[i][0], h1[i][1], h2[j][1]]
				end
				j+=1
			end
			i+=1
		end	
		return modifications
	end

	def get_deletions(hash1, hash2)
		h1 = hash1.keys
		h2 = hash2.keys
		return (h1 - h2) - (h2 - h1)
	end

	def get_conflicts(src_modifications, tgt_modifications, src_additions, tgt_additions)
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

		return merge_conflicts.uniq
	end

	def merge(rh_s, rh_t, common)
		if (common.next != nil && common.commitId == rh_t.tail.commitId)
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
				clear_file_list = list_files(rh_s.currPath)
				clear_file_list.each{|f| FileSystem.cpy(rh_s.currPath + f, rh_t.currPath)}
			else
				raise 'source or target revision history is corrupted'
			end

			rh_t.rh2Text()

			return 1
		elsif (common.next == nil && common.commitId == rh_t.tail.commitId)
			puts 'Repositories are identical, no need to push/pull'
			return 0
		elsif (common.next != nil && common.commitId != rh_t.tail.commitId)
			#3-way merge
			cursor = rh_t.tail
			while (cursor.commitId != common.commitId)
				cursor = cursor.prev
			end

			lca_hashes = common.fileHash
			src_hashes = rh_s.tail.fileHash
			target_hashes = rh_t.tail.fileHash

			src_deletions = get_deletions(lca_hashes, src_hashes)
			tgt_deletions = get_deletions(lca_hashes, target_hashes)

			src_additions = get_additions(lca_hashes, src_hashes)
			src_modifications = get_modifications(lca_hashes, src_hashes)
			tgt_additions = get_additions(lca_hashes, target_hashes)
			tgt_modifications = get_modifications(lca_hashes, target_hashes)

			all_deletions = src_deletions + tgt_deletions
			# p src_additions
			# p tgt_additions

			merge_conflicts = get_conflicts(src_modifications, tgt_modifications, src_additions, tgt_additions)

			if merge_conflicts.length > 0
				prompt = "Merge Conflict \n"
				for conflict in merge_conflicts
					if conflict[1] == "addition"
						prompt += conflict[0] + " has addition conflict \n"
						prompt += "add => " + conflict[2][0..3] + "..." + conflict[2][36..39] +"\n"
						prompt += "add => " + conflict[3][0..3] + "..." + conflict[3][36..39] +"\n"
						prompt += "Could not be resolved \n"
						prompt += "\n"
					else
						prompt += conflict[0] + " has modification conflict \n"
						prompt += conflict[1][0..3] + "..." + conflict[1][36..39] + " => " + conflict[2][0..3] + "..." + conflict[2][36..39] +"\n"
						prompt += conflict[1][0..3] + "..." + conflict[1][36..39] + " => " + conflict[3][0..3] + "..." + conflict[3][36..39] +"\n"
						prompt += "Could not be resolved \n"
						prompt += "\n"
					end
				end
				puts prompt
			else
				
				merge_node = RevisionNode.new()
				common_file_hash = common.fileHash
				h_add_s = Hash[*src_additions.flatten]
				h_add_t = Hash[*tgt_additions.flatten]
				h_mod_s = Hash[*strip_modification(src_modifications).flatten]
				h_mod_t = Hash[*strip_modification(tgt_modifications).flatten]
				common_file_hash = common_file_hash.merge(h_add_s)
				common_file_hash = common_file_hash.merge(h_add_t)
				common_file_hash = common_file_hash.merge(h_mod_s)
				common_file_hash = common_file_hash.merge(h_mod_t)
				for deletion in all_deletions
					common_file_hash.delete(deletion)
				end
				merge_node.fileHash = common_file_hash
				merge_node.commitId = nil
				merge_node.commitMsg = ('Merged ' + rh_s.currPath + ' to ' + rh_t.currPath)
				merge_node.state = 3
				merge_node.next = nil
				merge_node.time = DateTime.now.to_s
				commitId = rh_t.calcHash(merge_node)
				merge_node.commitId = commitId
				# puts "-----------commit--------------"

				# puts ""
				# p rh_s.tail
				# puts ""
				# p rh_t.tail
				# puts "---------------"
				while (rh_s.tail.prev != nil)
					if (rh_s.tail.commitId == common.commitId)
						break
					end
					rh_s.tail = rh_s.tail.prev
				end
				while (rh_t.tail.prev != nil)
					if (rh_t.tail.commitId == common.commitId)
						break
					end
					rh_t.tail = rh_t.tail.prev
				end

				# p merge_node


				# puts "--------------"
				rh_t.tail.next = merge_node
				rh_t.tail.next.prev = rh_t.tail
				rh_t.tail = rh_t.tail.next
				rh_s.tail.next = merge_node
				rh_s.tail.next.prev = rh_s.tail
				rh_s.tail = rh_s.tail.next
				rh_s.commitMap[commitId] = merge_node
				rh_t.commitMap[commitId] = merge_node

				# puts rh_s.log
				# puts ""
				# puts rh_t.log

				# puts rh_s.commitMap.keys
				# puts rh_t.commitMap.keys

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
				
				rh_t.checkout(commitId)
				rh_s.checkout(commitId)
				rh_t.rh2Text()
				rh_s.rh2Text()

			end
			return 2
		else
			raise 'impossible lca, source, target tuples'
			return -1
		end
	end

	def strip_modification(modifications)
		result = []
		for i in modifications
			result << [i[0], i[2]]
		end
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