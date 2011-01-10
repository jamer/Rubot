
class Typo < RubotPlugin
	@@last_msg = {}

	def privmsg(user, source, message)
		if message.match /^s\/(.*)\/(.*)\/?/
			return unless @@last_msg[user.nick]
			orig = $1
			new = $2
			msg = @@last_msg[user.nick].sub! /#{orig}/, new
			say source, "#{user.nick} meant to say: #{msg}"
		else
			@@last_msg[user.nick] = message
		end
	end

end

