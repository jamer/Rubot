class Cooldown
	def initialize(seconds)
		@last = 0
		@cooldown = seconds
	end

	def trigger
		if ready_now?
			@last = now
			return true
		else
			return false
		end
	end

	def ready_now?
		return !too_soon(now)
	end

	def ready_in
		return (@last + @cooldown) - now
	end

	def too_soon(time)
		return time < @last + @cooldown
	end

	def now
		return Time.now.to_i
	end
end

