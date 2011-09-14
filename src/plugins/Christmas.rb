class Christmas < RubotPlugin
	def initialize
		super
	end

	def on_privmsg(user, source, msg)
		if msg.match(/^merry.*christmas/i)
			say(source, "Merry Christmas, #{user.nick}!")
		end
	end
end

