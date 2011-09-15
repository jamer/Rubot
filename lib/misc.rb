
def log(msg)
	line = "[#{Time.now.strftime("%F %T")}] #{msg}"
	puts line
	open "log.txt", "a" do |f|
		f.puts line
	end
end

class String
	def scrape!(regex)
		# Scrapes off a regex from a string, and returns the captures.
		# If the regex is found inside the string, it is removed.
		return nil unless (m = match regex)
		gsub! regex, ""
		return m.captures
	end

	def capitalize_each_word!
		capitalize!
		for i in (1...length)
			self[i] -= 32 if self[i-1] == 32
		end
		return self
	end
end

class Array
	def random
		return self[rand length]
	end
end

module Enumerable
	def map_first(&block)
		each do |el|
			x = yield el
			return x if x
		end
		return nil
	end
end


def show_stack_trace
	begin
		raise "Stack trace"
	rescue Exception => e
		puts e.backtrace
	end
end


