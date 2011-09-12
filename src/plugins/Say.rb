
class Say < RubotPlugin

	@@privmsg_actions = {
		/^say (.+)/i => :speak,
		/^tell (\S+) (.+)/i => :speak_to,
	}

	def privmsg(user, source, message)
		@source = source

		al = RegexJump.new @@privmsg_actions, self
		if al.parse(message, [source]) then
			log "SAY #{user.nick} issued command \"#{message}\""
			Sources.update
			return true
		else
			return false
		end
	end

	def speak(source, message)
		say source, message
	end

	def speak_to(source, target, message)
		say target, message
	end

end

