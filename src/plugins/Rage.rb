
class Rage < RubotPlugin
	@@privmsg_actions = {
		/the game/i => :rage,
	}

	def initialize
		@cnt = 0
	end

	def privmsg(user, source, message)
		al = RegexJump.new @@privmsg_actions, self
		return al.parse(message, [user.nick, source])
	end

	def rage nick, source
		@cnt += 1
		if @cnt == 3
			say source, "explodes at #{nick}! >:(", :action
			@cnt = 0
		else
			say source, "Grr... #{nick}. :("
		end
	end
end

