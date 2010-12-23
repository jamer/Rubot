class Cooldown
	attr_accessor :duration

	def initialize(duration)
		@duration = duration
		@last_use = 0
	end

	def ready?
		now > @last_use + @duration
	end

	def trigger
		@last_use = now
	end

	def to_s
		"#{@duration}"
	end

private
	def now
		Time.now.to_i
	end

end

