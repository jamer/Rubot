class Lonely < RubotPlugin

	attr_accessor :chance

	@@messages = [
		"I'm cold...",
		"It's dark in here...",
		"I'm scared...",
		"Hello?",
		"I don't feel too well...",
		"Wait, what?",
		"I don't understand...",
	]

	def initialize
		@chance = 1
		@cool = Cooldown.new 5
	end

	def privmsg(user, reply_to, message)
		i = rand 100
		speak = i < @chance
		be_lonely if speak and @cool.ready?
	end

	def be_lonely
		@cool.trigger
		say reply_to, @@messages.random if speak
	end

end

