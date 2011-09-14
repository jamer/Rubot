class Eval < RubotPlugin
	include Math

	def initialize
		super
		@eval_timeout = 2
	end

	def on_privmsg(user, reply_to, message)
		match = message.match(/^do (.+)/i)
		return false if !match
		expression = match[1]
		eval_in_new_thread reply_to, expression
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

