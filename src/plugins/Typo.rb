
class Typo < RubotPlugin
	@@remembered = 10
	@@last_msg = {}

	def user_said nick, message
		unless @@last_msg[nick]
			@@last_msg[nick] = Array.new
		end

		@@last_msg[nick].push message
		if @@last_msg[nick].length > @@remembered
			@@last_msg[nick].shift
		end
	end

	def privmsg user, source, message
		nick = user.nick
		if message.match /^s\/(.+)\/(.+)/
			return unless @@last_msg[nick]
			orig = $1
			cor = $2
			cor.chop! if cor[-1..-1] == "/"
			found = @@last_msg[nick].grep(/#{orig}/).last
			return unless found
			corrected = found.sub /#{orig}/i, cor
			say source, "#{nick} meant to say: #{corrected}"
			user_said nick, corrected
		else
			user_said nick, message
		end
	end

end

