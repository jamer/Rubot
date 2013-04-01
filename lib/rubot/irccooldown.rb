require 'lib/cooldown'

class IRCCooldown < Cooldown
	def initialize(client, seconds, error_msg)
		super(seconds)
		@client = client
		@given_err
		@error_msg = error_msg
	end
	
	def trigger_err(channel)
		if ready_now?
			@given_err = false
			trigger
			return true
		elsif not @given_err
			@client.say(channel, @error_msg % [ready_in, (ready_in > 1) ? "s" : ""])
			@given_err = true
			return false
		else
			return false
		end
	end
end
