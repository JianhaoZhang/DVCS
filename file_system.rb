require 'fileutils'

module FileSystem
	def init()
	  	if Dir.exist?('./.dvcs')
	  		raise 'cannot create directory .dvcs: directory exists!' 
		else
			Dir.mkdir './.dvcs'
			out_file = File.new(File.join("./.dvcs", "revision_history_file"), "w")
			out_file.close
	end

	def clone(pth)
		if Dir.entries("#{pth}").select {|entry| File.directory? entry}.include? '.dvcs'
			FileUtils.cp_r "#{pth}", './'
		else
			raise 'source dir is not a dvcs project!' 
		end
	end

	def store_rh(l_strings)
		open(File.join("./.dvcs", "revision_history_file"), "a") { |f|
  			l_strings.each { |element| f.puts(element) }
		}
	end

	def get_rh()
		text = []
		File.foreach(File.join("./.dvcs", "revision_history_file")) do |line|
		  text << line
		end

		text
	end

	def diff(file1, file2)
		a = open(file1, "r").read.split("\n")
		b = open(file2, "r").read.split("\n")
		if a.length != b.length
			(a.length > b.length)? (0...(a.length-b.length)).to_a.each {|_| b << nil} : (0...(b.length-a.length)).to_a.each {|_| a << nil}
		end
		diff_list = []

		a.each_with_index {|val,index| diff_list << [index, a[index], b[index]] if val != b[index]}
		diff_list
	end
  end
end

class DVCS
	include FileSystem
end

dvcs_file = DVCS.new
dvcs_file.init()
# dvcs_file.clone('/u/zkou2/Code/453/p2')
# dvcs_file.store_rh(['a', 'b', 'c'])
p dvcs_file.diff('file1', 'file2')