#!/usr/bin/ruby
# BookServ
# An IRC bot that serves books.

# Tabs are 2 spaces in length. Set your editor to this.

require 'socket'

require 'sources.rb'

Sources.this_is(__FILE__)
Sources << "irc.rb"
Sources << "library.rb"
Sources << "misc.rb"

run_only_once :defines do
	SERVER = "irc.omegadev.org"
	PORT = 6667

	NICK = "LibApprentice"
	HOST = REALNAME = "localhost"
	CHANNEL = "#bot"
end


class Librarian

	def start_duties
		@irc = IRC.new(HOST, SERVER, PORT, NICK, REALNAME, CHANNEL, self)
		@irc.connect

		# If we get an exception, then print it out and keep going
		# We do NOT want to disconnect unexpectedly!
		begin
			@irc.main_loop
		rescue Interrupt
		rescue Exception => detail
			puts detail.message
			print detail.backtrace.join "\n"
			retry
		end
	end

	def say(message, channel = nil)
		@irc.say(message, channel)
	end

	def user_message(nick, command)
		log "#{nick} issued command \"#{command}\""
		case command
		when /^open (.+)/i
			title = $1
			book = Library.get_book title
			if book.nil?
				say "Book not found."
				return
			end
			say "Ahh, here we go. For some reason it was in the basement. " +
					"Happy reading!"
			UserBase.get_user(nick).book = book
		when /^catalog$/i
			Library.list_books.each { |line| say line }
		when /^read$/i
			user = UserBase.get_user(nick)
			say user
			book = user.book
			if book.nil?
				say "You need to open a book before you can start reading."
				return
			end
=begin
			user.read.each do |line|
				msg line, nick
			end
=end
		when /^resume$/i
			user = UserBase.get_user(nick)
			book = user.book
			if book.nil?
				say @@resume_needs_book.random
				return
			end
			user.resume.each do |line|
				say line, nick
			end
		when /^start over$/i
			user = UserBase.get_user(nick)
			if user.book.nil?
				say "Whaaatt? Go back to the beginning? " +
						"You haven't even started reading a book yet."
				return
			end
			say "Flipping back to the first page. " +
					"You used to be at line #{user.line}."
			user.line = 0
		when /^chunk$/i
			chunk = UserBase.get_user(nick).chunk
			say "For you, books will be delivered in #{chunk}-line chunks."
		when /^set chunk (\d+)$/i
			chunk = $1.to_i
			if chunk == 0
				say @@chunk_required.random
				return
			elsif chunk > 1000
				chunk = 1000
				say @@too_much_chunk.random % [chunk, chunk]
			else
				say @@new_chunk_size.random % chunk
			end
			UserBase.get_user(nick).chunk = chunk
		when /^help$/i
			say @@help_msg
		end
	end

	@@resume_needs_book = [
		"You need to start reading before you can resume.",
		"You don't have a book open yet.",
		"I don't think you've chosen a book yet, sweetie.",
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
		"    open <book>",
		"    catalog",
		"    read",
		"    resume",
		"    chunk",
		"    set chunk <size>",
	]

end

run_only_once :program do
	Librarian.new.start_duties
end

