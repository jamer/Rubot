class Rage < RubotPlugin
	@@actions = {
		/the game/i => :rage,
	}

	def initialize
		super
		@cnt = 0
	end

	def on_privmsg(user, source, line)
		RegexJump::jump(@@actions, self, line, [user.nick, source])
	end

	def rage(nick, source)
		@cnt += 1
		if @cnt == 3
			say(source, "explodes at #{nick}! >:(", :action)
			@cnt = 0
		else
			say(source, "Grr... #{nick}. :(")
		end
	end
end

