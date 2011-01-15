
class Idle < RubotPlugin

	def initialize
		Thread.new do
			sleep 5
			@client.join "#bots"
		end
	end

	def privmsg user, source, message
		return nil
	end

end

