class Rooval < RoobotPlugin

	def privmsg_listener(nick, realname, host, source, message)
		match = message.match(/^do (.+)/i)
		return false if !match
		expression = match[1]
		if host == "Admin.omegadev.org"
			Sources.update
			log "EVAL #{expression} from #{nick}!#{realname}@#{host}"
			say source, evaluate(expression)
		end
	end

	def evaluate(s)
		begin
			return eval(s).to_s
		rescue Exception => detail
			return detail.message
		end
		return "Error"
	end

end

