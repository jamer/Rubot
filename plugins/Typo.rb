class Typo < RubotPlugin
	def initialize
		super

		# Remember this many previous lines for each user.
		@remembered = 10

		# This will hold previous messages from all users we see.
		@msgs = {}
	end

	def user_said(nick, msg)
		# A user said something, let's write it down.
		unless @msgs[nick]
			@msgs[nick] = Array.new
		end

		@msgs[nick].push(msg)
		if @msgs[nick].length > @remembered
			@msgs[nick].shift
		end
	end

	def replace(source, nick, orig, cor)
		return unless @msgs[nick]
		found = @msgs[nick].grep(/#{orig}/).last
		return unless found
		corrected = found.sub(/#{orig}/i, cor)
		say(source, "#{nick} meant to say: #{corrected}")
		user_said(nick, corrected)
	end

	def on_privmsg(user, source, msg)
		if msg.match(/^s\/(.+)\/(.+)/)
			nick = user.nick
			orig, cor = $1, $2
			cor.chop! if cor[-1..-1] == "/"
			replace(source, nick, orig, cor)
		elsif msg.match(/^(.+?)\/(.+)\/(.+)/)
			nick, orig, cor = $1, $2, $3
			cor.chop! if cor[-1..-1] == "/"
			replace(source, nick, orig, cor)
		elsif msg.match(/^([^:]+): s\/(.+)\/(.+)/)
			say(source, "match")
		else
			nick = user.nick
			if msg.match(/\001/)
				msg.sub!(/^\001ACTION/, "* " + user.nick)
				msg.sub!(/\001$/, "")
			end
			user_said(nick, msg)
		end
	end
end

