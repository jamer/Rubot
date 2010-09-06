
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
			Kernel::load @file
			return true
		end
		return false
	end
end

class Sources
	@files ||= Hash.new
	@ignore ||= Hash.new

	# Open our singleton
	class << self

		def start_tracking(file)
			return false if @files.include? file or @ignore.include? file
			sf = SourceFile.new file
			@files[file] = sf
			return true
		end

		def require(file)
			if start_tracking file
				Kernel::load file
			end
		end

		def require_all(files)
			files.each { |file| self.require file }
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

	end
end

def up
	return Sources.update
end

