
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

class Sources
	@files ||= Hash.new

	# Open our singleton
	class << self

		def add_file(file)
			return false if @files.include? file
			sf = SourceFile.new file
			@files[file] = sf
			return true
		end

		def require(file)
			load file if add_file file
		end

		def update
			# Update files that have been modified since we ran
			got_one = false
			@files.each_value { |file| got_one = true if file.update }
			return got_one
		end

	end
end

def run_only_once(id)
	$sections ||= {}
	if not $sections[id]
		$sections[id] = true
		yield
	end
end

def up
	return Sources.update
end

run_only_once :sources do
	Sources.add_file __FILE__
end

