
class Typo < RubotPlugin

	def initialize
		# Remember this many previous lines for each user.
		@remembered = 10

		# This will hold previous messages from all users we see.
		@msgs = {}
	end

	def user_said nick, message
		# A user said something, let's write it down.
		unless @msgs[nick]
			@msgs[nick] = Array.new
		end

		@msgs[nick].push message
		if @msgs[nick].length > @remembered
			@msgs[nick].shift
		end
	end

	def replace source, nick, orig, cor
		return unless @msgs[nick]
		found = @msgs[nick].grep(/#{orig}/).last
		return unless found
		corrected = found.sub /#{orig}/i, cor
		say source, "#{nick} meant to say: #{corrected}"
		user_said nick, corrected
	end

	def on_privmsg user, source, message
		if message.match /^s\/(.+)\/(.+)/
			nick = user.nick
			orig, cor = $1, $2
			cor.chop! if cor[-1..-1] == "/"
			replace source, nick, orig, cor
		elsif message.match /^(.+?)\/(.+)\/(.+)/
			nick, orig, cor = $1, $2, $3
			cor.chop! if cor[-1..-1] == "/"
			replace source, nick, orig, cor
		elsif message.match /^([^:]+): s\/(.+)\/(.+)/
			say source, "match"
		else
			nick = user.nick
			if message.match /\001/
				message.sub! /^\001ACTION/, "* " + user.nick
				message.sub! /\001$/, ""
			end
			user_said nick, message
		end
	end

end

