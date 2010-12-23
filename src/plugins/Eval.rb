class Eval < RubotPlugin
	include Math

	def initialize
		@eval_timeout = 2
	end

	def privmsg(user, reply_to, message)
		match = message.match(/^do (.+)/i)
		return false if !match
		expression = match[1]
		if user.host == "Admin.omegadev.org" || # Jamer
				user.host == "For.The.Win" || # Cam
				user.host == "n0v4.com" || # kPa
				user.host == "The.Other.White.Hork.org" || # hork
				user.host == "randomly.bans.people.org" || # banhammer
				user.host == "Hh2.com" || # HACKhalo2
				user.host == "n0v4-C38C3F24.resnet.mtu.edu" || # runner
				user.host == "n0v4-2692EFCE.cda1.par.lon2.fbi.gov" # sti
						# Anon7-2521 some.other.hostname
						# Fem boxxy.babee
			Sources.update
#			log "EVAL #{expression} from #{user.nick}!#{user.name}@#{user.host}"
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

