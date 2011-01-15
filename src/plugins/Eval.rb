class Eval < RubotPlugin
	include Math

	def initialize
		@eval_timeout = 2
	end

	def privmsg(user, reply_to, message)
		match = message.match(/^do (.+)/i)
		return false if !match
		expression = match[1]
		if user.nick == "Jamer" || user.nick == "Anon7-2521"
#			log "EVAL #{expression} from #{user.nick}!#{user.name}@#{user.host}"
			if expression.match(/\003$/)
				expression.chop!
			end
			eval_in_new_thread reply_to, expression
		end
	end

	def eval_in_new_thread(reply_to, expr)
		thr = Thread.new do
			say reply_to, evaluate(expr)
		end

		thr.kill if not thr.join @eval_timeout
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

	def method_missing(symbol, *args)
			@client.send symbol, *args
	end

end

