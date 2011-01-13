
class Typo < RubotPlugin

	# Remember this many previous lines for each user.
	@@remembered = 10

	# This will hold previous messages from all users we see.
	@@last_msg = {}

	def user_said nick, message
		# A user said something, let's write it down.
		unless @@last_msg[nick]
			@@last_msg[nick] = Array.new
		end

		@@last_msg[nick].push message
		if @@last_msg[nick].length > @@remembered
			@@last_msg[nick].shift
		end
	end

	def replace source, nick, orig, cor
		return unless @@last_msg[nick]
		found = @@last_msg[nick].grep(/#{orig}/).last
		return unless found
		corrected = found.sub /#{orig}/i, cor
		say source, "#{nick} meant to say: #{corrected}"
		user_said nick, corrected
	end

	def privmsg user, source, message
		if message.match /^s\/(.+)\/(.+)/
			nick = user.nick
			orig = $1
			cor = $2
			cor.chop! if cor[-1..-1] == "/"
			replace source, nick, orig, cor
		elsif message.match /^(.+?)\/(.+)\/(.+)/
			nick = $1
			orig = $2
			cor = $3
			cor.chop! if cor[-1..-1] == "/"
			replace source, nick, orig, cor
		else
			nick = user.nick
			message.sub! /^\001ACTION/, "* " + user.nick
			user_said nick, message
		end
	end

end

