class Christmas < RubotPlugin
	def on_privmsg(user, source, message)
		if message.match /^merry.*christmas/i
			say source, "Merry Christmas, #{user.nick}!"
		end
	end
end

