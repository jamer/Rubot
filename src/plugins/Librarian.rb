# Librarian
# A Rubot plugin that serves books.

# Rather than code an ugly case statement for the Librarian's functions, we opt
# for a more mathematical model. We describe how the different methods relate
# to simple Regexps, and we ask Ruby to link them up for us.

class Librarian < RubotPlugin

	@@actions = {
		/^catalog$/i => :catalog,
		/^open (.+)/i => :open,
		/^read$/i => :read,
		/^resume$/i => :resume,

		/^start over$/i => :start_over,
		/^jump to (\d+)$/i => :jump_to,

		/^chunk$/i => :get_chunk,
		/^set chunk (\d+)$/i => :set_chunk,

		/^help$/i => :help,
	}

	def privmsg(user, reply_to, message)
		return false unless message =~ /^>(.+)/i
		command = $1.strip
		@reply_to = reply_to
		@nick = user.nick

		al = RegexJump.new @@actions, self
		if al.parse(command, [user.nick]) then
			log "LIBRARIAN #{user.nick} issued command \"#{command}\""
			Sources.update
			return true
		else
			return false
		end
	end

	def respond(message)
		say @reply_to, message
	end

	def private_respond(message)
		say @nick, message
	end

	def open(nick, title)
		book = Library.get_book title
		if book.nil?
			respond "Book not found."
			return
		end
		respond "Ahh, here we go. For some reason it was in the basement. " +
						"Happy reading!"
		UserBase[nick].book = book
	end

	def catalog
		Library.list_books.each { |line| respond line }
	end

	def read(nick)
		user = UserBase[nick]
		book = user.book
		if book.nil?
			respond "You need to open a book before you can start reading."
			return
		end
		private_respond user.read
	end

	def resume(nick)
		user = UserBase[nick]
		book = user.book
		if book.nil?
			say @@resume_needs_book.random
			return
		end
		user.resume.each { |line| private_respond line }
	end

	def start_over(nick)
		user = UserBase[nick]
		if user.book.nil?
			respond "Whaaatt? Go back to the beginning? " +
				"You haven't even started reading a book yet."
			return
		end
		respond "Flipping back to the first page. " +
			"You used to be at line #{user.line}."
		user.line = 0
	end

	def jump_to(nick)
		user = UserBase[nick]
		if user.book.nil?
			respond "Whaaatt? Search the book? " +
				"You haven't even started reading a book yet."
			return
		end
		respond @@line_set_to.random % line
		UserBase[nick].line = line
	end

	def get_chunk(nick)
		chunk = UserBase[nick].chunk
		respond "For you, books will be delivered in #{chunk}-line chunks."
	end

	def set_chunk(nick, chunk)
		if chunk == 0
			respond @@chunk_required.random
			return
		elsif chunk > 1000
			chunk = 1000
			respond @@too_much_chunk.random % [chunk, chunk]
		else
			respond @@new_chunk_size.random % chunk
		end
		UserBase[nick].chunk = chunk
	end

	def help
		respond @@help_msg
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

