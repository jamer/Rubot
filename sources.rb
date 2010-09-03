
class Sources
	@files ||= Hash.new
	@ignore ||= Hash.new
	@run_code ||= Hash.new

	# Open our singleton
	class << self

		def add_file(file)
			return false if @files.include? file or @ignore.include? file
			sf = SourceFile.new file
			@files[file] = sf
			return true
		end

		def load(file)
			require file if add_file file
		end

		def load_all(files)
			files.each { |file| self.load file }
		end

		def ignore(file)
			@ignore[file] = true
		end

		def update
			# Update files that have been modified since we ran
			got_one = false
			@files.each_value { |file| got_one = true if file.update }
			return got_one
		end

		def run(id = __FILE__)
			if not @run_code.include? id
				@run_code[id] = true
				yield
			end
		end

	end
end

class SourceFile
	def initialize(file)
		@file = file
		@current = File.new(file).mtime.to_i
	end

	def update
		modded = File.new(@file).mtime.to_i
		if modded > @current
			since = Time.now.to_i - modded
			log "SOURCES Updated #{@file}; changed #{since} seconds ago."
			@current = modded
			load @file
			return true
		end
		return false
	end
end

def up
	return Sources.update
end


Sources.run do
	Sources.add_file __FILE__
end

