# Attacks users if the channel is idle of a period of time.

class Orc < RubotPlugin

	Second = 1.0

	@@attacks = [
		"attacks %s with an ax!",
		"rages against the silence! " +
				"Unfortunately, it looks like he's taking his rage out on %s!",
		"doesn't like the eerie silence and is getting nervious...",
		"glares at %s with glowing red eyes.",

	]

	def initialize
		@cooldown = Cooldown.new 300
		@cooldown.trigger
		@channel = "#libby"
		@thread = Thread.new { grumble }
		@attacked_yet = false
	end

	def privmsg(user, reply_to, message)
		@cooldown.trigger
		@lastuser = user
		@attacked_yet = false
	end

	def grumble
		every 10*Second do
			if @lastuser and @cooldown.ready? and not @attacked_yet
				@attacked_yet = true
				say @channel, @@attacks.choice % @lastuser.nick, :action
			end
		end
	end

	def every(period)
		loop do
			sleep period
			yield
		end
	end

end

