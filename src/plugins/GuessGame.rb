
class GuessGame < RubotPlugin
	# Random number guessing game.

	def initialize
		@privmsg_actions = {
			/:guess/i => :start_game,
			/:#\s*(\d+)/ => :do_guess,
		}
	end

	def privmsg user, source, message
		@source = source

		al = ActionList.new @privmsg_actions, self
		return al.parse message, [user.nick, source]
	end

	def start_game nick, source
		@number = rand 500
		say source, "I have chosen a random number between 0 and 499"
	end

	def do_guess nick, source, guess
		if @number.nil?
			start_game nick, source
		end

		if guess == @number
			say source, "#{nick}: You got it!"
			@number = nil
		elsif guess < @number
			say source, "#{nick}: Higher."
		elsif guess > @number
			say source, "#{nick}: Lower."
		end
	end
end

