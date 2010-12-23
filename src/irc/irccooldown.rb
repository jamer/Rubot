class IRCCooldown < Cooldown
	def initialize(duration, sayer, not_ready_msg)
		super duration
		@sayer = sayer
		@not_ready_msg = not_ready_msg
		@msg_cooldown = Cooldown.new duration
	end

	def irc_ready?(reply_to)
		return true if ready?
		give_msg reply_to
		return false
	end

	def give_msg(reply_to)
		return unless @msg_cooldown.ready?
		@msg_cooldown.trigger
		@sayer.say reply_to, @not_ready_msg % @duration
	end
end

