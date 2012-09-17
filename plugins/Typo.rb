class Typo < RubotPlugin

	# Attention: Matches that look like numbers will be converted to numbers, and
	# will no longer be strings.
	@@actions = [
		[/^s\/(.+)\/(.+?)\/?$/                 , :correct_self],  # s/old/new/
		[/^s,(.+),(.+?),?$/                    , :correct_self],  # s,old,new,
		[/^(\S+?)\/(.+)\/(.+?)\/?$/            , :correct_other], # nick/old/new/
		[/^(\S+?),(.+),(.+?),?$/               , :correct_other], # nick,old,new,
# broken
#		[/^([^:,]+)[:,\s].*?s\/(.+)\/(.+?)\/?$/, :correct_other], # nick: s/old/new/
		[/(.+)/, :remember_line],
	]

	def initialize
		super

		# Remember this many previous lines for each user.
		@remembered = 10

		# This will hold previous messages from all users we see.
		@msgs = {}
	end

	def on_privmsg(user, source, msg)
		RegexJump::jump(@@actions, self, msg, [user, source])
	end

	# A user said something, let's write it down.
	def add_history_item(nick, msg)
		@msgs[nick] = Array.new unless @msgs[nick]
		@msgs[nick].unshift(msg)
		@msgs[nick].pop if @msgs[nick].length > @remembered
	end

	def replace(source, nick, orig, cor)
		orig = orig.to_s
		cor = cor.to_s

		return unless @msgs[nick]
		found = @msgs[nick].find {|msg| msg =~ /#{orig}/ }
		return unless found
		corrected = found.sub(/#{orig}/i, cor)
		say(source, "#{nick} meant to say: #{corrected}")
		add_history_item(nick, corrected)
	end

	def correct_self(user, source, orig, cor)
		nick = user.nick
		replace(source, nick, orig, cor)
	end

	def correct_other(user, source, nick, orig, cor)
		replace(source, nick, orig, cor)
	end

	def remember_line(user, source, msg)
		msg = msg.to_s

		nick = user.nick
		if msg =~ /^\001/
			msg.sub!(/^\001ACTION/, "* #{user.nick}")
			msg.sub!(/\001$/, "")
		end
		add_history_item(nick, msg)
	end
end

