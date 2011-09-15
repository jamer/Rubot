class Lonely < RubotPlugin
	attr_accessor :chance

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
		i = rand(100)
		speak = i < @chance
		say(source, @@messages.random) if speak
	end
end

