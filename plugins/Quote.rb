class Quote < RubotPlugin
	@@file = "quotes.txt"

	@@actions = [
		[/^:quote add (.+)/i, :add],
		[/^:quote show (\d+)/i, :show],
		[/^:quote find (.+)/i, :find],
	]

	def initialize
		super
	end

	def on_privmsg(user, source, msg)
		RegexJump::jump(@@actions, self, msg, [source])
	end

	def add(source, quote)
		open(@@file, "a") do |file|
			file.puts(quote)
		end
		count = IO.readlines(@@file).length
		say(source, "Quote ##{count} added")
	end

	def show(source, index)
		lines = IO.readlines(@@file)
		if index < 0 || index > lines.length
			say(source, "Invalid index")
		else
			say(source, lines[index-1])
		end
	end

	def find(source, term)
		lines = IO.readlines(@@file)
		matches = lines.zip((1..lines.length).to_a).select { |line, i|
			line =~ /#{term}/
		}.map { |line, i| i }
		if matches.length
			say(source, "Found term in quotes: #{matches.join(' ')}")
		else
			say(source, "Didn't find term in any quotes")
		end
	end
end

