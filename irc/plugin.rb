
class RoobotPlugin

	def attach(bot)
		# Attach this plugin to a bot.
		@bot = bot

		if self.class.method_defined? :listener
			bot.add_listener method :listener
			@have_listener = true
		end
		if self.class.method_defined? :privmsg_listener
			bot.add_privmsg_listener method :privmsg_listener
			@have_privmsg_listener = true
		end
	end

	def detach
		if @have_listener
			@bot.remove_listener method :listener
		end
		if @have_privmsg_listener
			@bot.remove_privmsg_listener method :privmsg_listener
		end
	end

	def say(recipient, message)
		@bot.say recipient, message
	end

end

