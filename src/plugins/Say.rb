class Say < RubotPlugin
	@@actions = {
		/^say (.+)/i => :speak,
		/^tell (\S+) (.+)/i => :speak_to,
	}

	def privmsg(user, source, line)
		return RegexJump::jump(@@actions, self, line, [source])
	end

	def speak(source, message)
		say(source, message)
	end

	def speak_to(source, target, message)
		say(target, message)
	end
end

