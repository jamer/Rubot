class RubotPlugin
	attr_accessor :client

	def say(recipient, message, action = :privmsg)
		# Convenience method for saying something.
		@client.say(recipient, message, action)
	end
end

