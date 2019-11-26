require 'digest'
require 'fileutils'
require 'digest/sha1'

module FileSystem
	def FileSystem.init()
	  	if Dir.exist?('./.dvcs')
	  		puts 'cannot create directory .dvcs: directory exists!'
	  		0 
		else
			Dir.mkdir './.dvcs'
			out_file = File.new(File.join("./.dvcs", "revision_history_file"), "w")
			out_file.close
			1
		end
	end

	def FileSystem.clone(pth)
		if Dir.entries("#{pth}").select {|entry| File.directory? entry}.include? '.dvcs'
			FileUtils.cp_r "#{pth}", './'
			0
		else
			puts 'source dir is not a dvcs project!' 
			1
		end
	end

	def FileSystem.store_rh(l_strings)
		if File.file?(File.join("./.dvcs", "revision_history_file"))
			open(File.join("./.dvcs", "revision_history_file"), "w") { |f|
	  			# l_strings.each { |element| f.puts(element) }
	  			# if l_strings.instance_of? String
				f.puts(l_strings)
  		# 		else
  		# 			l_strings.each {|e| f.puts(e)}
				# end
			}
			1
		else
			puts "no revision history file!"
			0
		end
	end

	def FileSystem.get_rh()
		if File.file?(File.join("./.dvcs", "revision_history_file"))
			text = []
			File.foreach(File.join("./.dvcs", "revision_history_file")) do |line|
			  text << line.strip
			end

			text
		else
			puts "no revision history file!"
			0
		end
	end

	def FileSystem.diff(file1, file2)
		if File.file?(file1) && File.file?(file2)
			a = open(file1, "r").read.split("\n")
			b = open(file2, "r").read.split("\n")
			if a.length != b.length
				(a.length > b.length)? (0...(a.length-b.length)).to_a.each {|_| b << nil} : (0...(b.length-a.length)).to_a.each {|_| a << nil}
			end
			diff_list = []

			a.each_with_index {|val,index| diff_list << [index, a[index], b[index]] if val != b[index]}
			diff_list
		else
			puts "file may not exist!"
			0
		end
	end

	def FileSystem.read(path)
		if File.file?(path)
			open(path,"r")
		else
			puts "file not exist!"
			0
		end
	end

	def FileSystem.write(path, string)
		if !File.file?(path)
			puts "no such a file!"
			0
		else
			open(path, 'w') { |f|
	  			f.puts(string)
			}
			1
		end
	end

	def FileSystem.cpy(path1, path2)
		if File.directory?(path1)
			FileUtils.cp_r "#{path1}", "#{path2}"
			1
		elsif File.file?(path1)
			FileUtils.cp "#{path1}", "#{path2}"
			1
		else
			0
		end
	end

	def FileSystem.getHash(pth)
		if File.file?(path)
			Digest::SHA1.hexdigest "#{pth}"
		else
			puts "no such a file"
			0
		end
	end

	def FileSystem.delete(pth)
		if File.directory?(pth)
			FileUtils.remove_dir(pth)
			1
		elsif File.file?(pth)
			File.delete(pth)
			1
		else
			0
		end
	end
end

# class DVCS
# 	include FileSystem
# end

# dvcs_file = DVCS.new
# dvcs_file.init()
# dvcs_file.clone('/u/zkou2/Code/453/p2')
# dvcs_file.store_rh(['a', 'b', 'c'])
# p dvcs_file.diff('file1', 'file2')
# p dvcs_file.write('file1','123')
# p dvcs_file.cpy('file1','file3')
# p dvcs_file.getHash('/u/zkou2/Code/DVCS/file1')
# p dvcs_file.delete('us')

# FileSystem.store_rh(["nline1", "nline2", "nline3", "nline4"])
# puts FileSystem.get_rh() == ["nline1", "nline2", "nline3", "nline4"]
# puts FileSystem.get_rh()[0].strip == ["nline1", "nline2", "nline3", "nline4"][0]
# puts ["nline1", "nline2", "nline3", "nline4"]

open("a.txt", "w") { |f|
	f.puts("1 2 3 4 5")
}

puts ["1 2 3 4 5"]
puts File.open("a.txt").to_a
