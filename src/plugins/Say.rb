
class Say < RubotPlugin

	@@privmsg_actions = {
		/^say (.+)/i => :speak,
		/^tell (\S+) (.+)/i => :speak_to,
	}

	def privmsg(user, source, message)
		@source = source

		al = ActionList.new @@privmsg_actions, self
		return al.parse(message, [source]) do
			log "SAY #{user.nick} issued command \"#{message}\""
			Sources.update
		end
	end

	def speak(source, message)
		say source, message
	end

	def speak_to(source, target, message)
		say target, message
	end

end

