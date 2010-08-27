#!/usr/bin/ruby
# BookServ
# An IRC bot that serves books.

# Tabs are 2 spaces in length. Set your editor to this.

require 'socket'

load "irc.rb"
load "library.rb"
load "misc.rb"

new = !defined? SOURCE

if new
	SERVER = "irc.omegadev.org"
	PORT = 6667

	NICK = "LibApprentice"
	HOST = REALNAME = "localhost"
	CHANNEL = "#bot"

	SOURCE = __FILE__
end


class Librarian

	# Open the Librarian singleton
	class << self

		@@help_msg = [
			"Commands must be prefixed with a greater-than (>) sign",
			"    open <book>",
			"    catalog",
			"    read",
			"    resume",
			"    chunk",
			"    set chunk <size>",
		]

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

		def msg(message, channel = nil)
			if channel
				@irc.channel_msg(message, channel)
			else
				@irc.channel_msg(message)
			end
		end

		def user_message(nick, command)
			log "#{nick} issued command \"#{command}\""
			case command
			when /^open (.+)/i
				title = $1
				book = Library.get_book title
				if book.nil?
					msg "Book not found."
					return
				end
				msg "Ahh, here we go. For some reason it was in the basement. " +
						"Happy reading!"
				UserBase.get_user(nick).book = book
			when /^catalog$/i
				Library.list_books.each { |line| msg line }
			when /^read$/i
				user = UserBase.get_user(nick)
				book = user.book
				if book.nil?
					msg "You need to open a book before you can start reading."
					return
				end
				user.read.each do |line|
					msg line, nick
				end
			when /^resume$/i
				user = UserBase.get_user(nick)
				book = user.book
				if book.nil?
					msg "You need to start reading before you can resume."
					return
				end
				user.resume.each do |line|
					msg line, nick
				end
			when /^chunk$/i
				chunk = UserBase.get_user(nick).chunk
				msg "For you, books will be delivered in #{chunk}-line chunks."
			when /^set chunk (\d+)$/i
				chunk = $1.to_i
				if chunk == 0
					msg "You need a chunk. You can't have none. :p"
				end
				if chunk > 1000
					msg "Whoa whoa whoa, I think 1000 is a big enough number, don't you?"
					msg "You've been set to a chunk of 1000"
					chunk = 1000
				end
				UserBase.get_user(nick).chunk = chunk
			when /^help$/i
				msg @@help_msg
			end
		end

	end
end

if new
	Librarian.start_duties
end

