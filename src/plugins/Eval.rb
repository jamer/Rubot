class Eval < RubotPlugin
	include Math

	def initialize
		super
		@eval_timeout = 2
	end

	def on_privmsg(user, source, message)
		return unless match = message.match(/^do (.+)/i)
		expression = match[1]
		eval_in_new_thread(source, expression)
	end

	def eval_in_new_thread(source, expr)
		thr = Thread.new do
			say(source, evaluate(expr))
		end

		thr.kill if not thr.join(@eval_timeout)
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
			@client.send(symbol, *args)
	end
end

