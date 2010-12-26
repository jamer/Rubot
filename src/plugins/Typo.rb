
class Typo < RubotPlugin
	@@last_msg = {}

	def privmsg(user, source, message)
		if message.match /^s\/(.*)\/(.*)\//
			return unless @@last_msg[user.nick]
			orig = $1
			new = $2
			msg = @@last_msg[user.nick]
			msg.sub! /#{orig}/, new
			say source, "#{user.nick} meant to say: #{msg}"
			@@last_msg[user.nick] = msg
		else
			@@last_msg[user.nick] = message
		end
#		if message.match /^merry.*christmas/i
#			say source, "Merry Christmas, #{user.nick}!"
#		end
	end

end

