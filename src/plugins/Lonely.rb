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

	def on_privmsg(user, reply_to, message)
		i = rand 100
		speak = i < @chance
		say reply_to, @@messages.random if speak
	end
end

