
class Sources
	@@running_from = Time.new

	# Open our singleton
	class << self

		def init_ourself
			@@files ||= { __FILE__ => true }
		end

		def this_is(file)
			init_ourself
			@@files[file] = true
		end

		def <<(file)
			init_ourself
			@@files[file] = true
			load file
		end

		def update
			# Update files that have been modified since we ran
			got_one = false

			@@files.each_key do |file|
				if File.new(file).mtime.to_i > @@running_from.to_i
					log "Updating" if got_one == false
					load file
					@@running_from = Time.new
					got_one = true
				end
			end

			return got_one
		end

	end
end


def run_only_once(desc)
	@@symbols ||= {}
	if not @@symbols[desc]
		@@symbols[desc] = true
		yield
	end
end


