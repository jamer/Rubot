class Quote < RubotPlugin
	@@file = "quotes.txt"

	@@privmsg_actions = {
		/^:add (.+)/i => :add,
		/^:show (\d+)/i => :show,
		/^:find (.+)/i => :find,
	}

	def privmsg user, reply_to, message
		al = ActionList.new @@privmsg_actions, self
		return al.parse(message, [reply_to])
	end

	def add reply_to, quote
		open(@@file, "a") do |file|
			file.puts quote
		end
		count = IO.readlines(@@file).length
		say reply_to, "Quote ##{count} added"
	end

	def show reply_to, index
		lines = IO.readlines @@file
		if index < 0 || index > lines.length
			say reply_to, "Invalid index"
		else
			say reply_to, lines[index-1]
		end
	end

	def find reply_to, term
		lines = IO.readlines @@file
		matches = lines.zip((1..lines.length).to_a).select { |line, i|
			line =~ /#{term}/
		}.map { |line, i| i }
		if matches.length
			say reply_to, "Found term in quotes: #{matches.join ' '}"
		else
			say reply_to, "Didn't find term in any quotes"
		end
	end

end

