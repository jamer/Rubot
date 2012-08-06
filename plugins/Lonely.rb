class Lonely < RubotPlugin
	@@messages = [
		"I'm cold...",
		"It's dark in here...",
		"I'm scared...",
		"Hello?",
	]

	def initialize
		super
		@chance = 2
	end

	def on_privmsg(user, source, msg)
		say(source, @@messages.random) if rand(100) < @chance
	end
end

