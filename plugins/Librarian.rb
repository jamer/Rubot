# Librarian
# A Roobot plugin that serves books.

# Roobot is an IRC bot framework written by Jamer.

# Rather than code an ugly case statement for the Librarian's functions, we opt
# for a more mathematical model. We describe how the different methods relate
# to simple Regexps, and we ask Ruby to link them up for us.

class Librarian < RoobotPlugin

	def privmsg_listener(nick, realname, host, source, message)
		if message =~ /^>(.+)/i
			command = $1.strip
			Sources.update
			return librarian_command source, nick, command
		end
		return false
	end

	@@actions = {
		:catalog => /^catalog$/i,
		:open => /^open (.+)/i,
		:read => /^read$/i,
		:resume => /^resume$/i,

		:start_over => /^start over$/i,
		:jump_to => /^jump to (\d+)$/i,

		:get_chunk => /^chunk$/i,
		:set_chunk => /^set chunk (\d+)$/i,

		:help => /^help$/i,
	}

	def librarian_command(source, nick, command)
		log "LIBRARIAN #{nick} issued command \"#{command}\""
		@source = source

		@@actions.each do |fn, regex|
			match = regex.match(command)
			next if !match

			args = [nick] + match.captures

			# Integer hack, change strings into integers if they match a regexp.
			args.map! do |arg|
				if arg =~ /^\d+$/
					arg = arg.to_i
				end
				arg
			end

			# Send the function only the number of args that it needs.
			arg_count = method(fn).arity
			send fn, *args.slice(0, arg_count)
			return true
		end

		return false
	end

	def say(message)
		@bot.say(@source, message)
	end

	def open(nick, title)
		book = Library.get_book title
		if book.nil?
			say "Book not found."
			return
		end
		say "Ahh, here we go. For some reason it was in the basement. " +
				"Happy reading!"
		UserBase[nick].book = book
	end

	def catalog
		Library.list_books.each { |line| say line }
	end

	def read(nick)
		user = UserBase[nick]
		book = user.book
		if book.nil?
			say "You need to open a book before you can start reading."
			return
		end
		say user.read, nick
	end

	def resume(nick)
		user = UserBase[nick]
		book = user.book
		if book.nil?
			say @@resume_needs_book.random
			return
		end
		user.resume.each do |line|
			say line, nick
		end
	end

	def start_over(nick)
		user = UserBase[nick]
		if user.book.nil?
			say "Whaaatt? Go back to the beginning? " +
				"You haven't even started reading a book yet."
			return
		end
		say "Flipping back to the first page. " +
			"You used to be at line #{user.line}."
		user.line = 0
	end

	def jump_to(nick)
		user = UserBase[nick]
		if user.book.nil?
			say "Whaaatt? Search the book? " +
				"You haven't even started reading a book yet."
			return
		end
		say @@line_set_to.random % line
		UserBase[nick].line = line
	end

	def get_chunk(nick)
		chunk = UserBase[nick].chunk
		say "For you, books will be delivered in #{chunk}-line chunks."
	end

	def set_chunk(nick, chunk)
		if chunk == 0
			say @@chunk_required.random
			return
		elsif chunk > 1000
			chunk = 1000
			say @@too_much_chunk.random % [chunk, chunk]
		else
			say @@new_chunk_size.random % chunk
		end
		UserBase[nick].chunk = chunk
	end

	def help
		say @@help_msg
	end

	@@resume_needs_book = [
		"You need to start reading before you can resume.",
		"You don't have a book open yet.",
		"I don't think you've chosen a book yet, sweetie.",
	]

	@@line_set_to = [
		"Let's just pretend you've read the first %d lines of the book already...",
	]

	@@chunk_required = [
		"You need a chunk. You can't have none. :p",
		"Zero means 'nothing,' and I can't permit you to have an absense of chunk.",
	]

	@@too_much_chunk = [
		"Whoa whoa whoa, I think %d is a big enough number, don't you?\n" +
		"You've been set to a chunk of %d",
		"Err, you say you want *more* than %d? \nI dunno... %d has always " +
		"been enough for me. So that's what I'm setting you to.",
	]

	@@new_chunk_size = [
		"I will now send you books in chunks of %d-lines at a time.",
		"Your books will now come in %d-line chunks.",
	]

	@@help_msg = [
		"Commands must be prefixed with a greater-than (>) sign",
		"    catalog",
		" ",
		"    open <book>",
		"    read",
		"    resume",
		" ",
		"    start over",
		"    jump to <line>",
		" ",
		"    chunk",
		"    set chunk <size>",
	]

end

