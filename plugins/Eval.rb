class Eval < RoobotPlugin

	def privmsg(user, reply_to, message)
		match = message.match(/^do (.+)/i)
		return false if !match
		expression = match[1]
		if user.host == "Admin.omegadev.org" || user.host == "For.The.Win"
			Sources.update
			log "EVAL #{expression} from #{user.nick}!#{user.username}@#{user.host}"
			eval_in_new_thread reply_to, expression
		end
	end

	def eval_in_new_thread(reply_to, expr)
		thr = Thread.new do
			say reply_to, evaluate(expr)
		end

		Thread.new do
			sleep 10
			thr.kill
		end
	end

	def evaluate(expr)
		begin
			return eval(expr)
		rescue Exception => detail
			return detail.message
		rescue SystemExit
			return "Exitting is disabled."
		end
	end

end

