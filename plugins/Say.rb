class Say < RubotPlugin
	@@actions = [
		[/^say (.+)/i, :speak],
		[/^tell (\S+) (.+)/i, :speak_to],
	]

	def initialize
		super
	end

	def on_privmsg(user, source, msg)
		RegexJump::jump(@@actions, self, msg, [source])
	end

	def speak(source, msg)
		say(source, msg)
	end

	def speak_to(source, target, msg)
		say(target, msg)
	end
end

