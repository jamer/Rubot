class Gandalph < RubotPlugin
	def privmsg(user, reply_to, message)
		if message == @client.nick + ", summon an army."
			@client.say reply_to, "summons an army.", :action
		end
	end
end

