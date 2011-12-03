# Laugh at command.
#
# Says "LOL" when someone types "laugh 1"
# Says "LOLO-" when someone types "laugh 1.5"
# Says "LOLOL" when someone types "laugh 2"
# Etc.
class Laugh < RubotPlugin
	@@actions = [
		[/^laugh\s*(\d+(\.\d)?)$/i, :laugh],
		[/lol/i, :laugh_random],
		[/rofl/i, :laugh_random],
		[/lmf?ao/i, :laugh_random],
	]

	def initialize
		super
		@cooldown = IRCCooldown.new(self, 5,
			"I can't laugh that fast. Wait %d more second%s.")
	end

	def on_privmsg(user, source, msg)
		RegexJump::jump(@@actions, self, msg, [source])
	end

	# Say "WOLOL" about 10% of the time.
	def first_char
		return rand(10) == 1 ? "W" : "L"
	end

	# Laugh "times" times. If times is a partial decimal, add an extra "O-"
	# to the end of it. Maximum number of times 25 (plus the O- if we're a
	# decimal).
	def laugh(source, times, unused)
		return unless @cooldown.trigger_err(source)
		decimal = (times.to_f != times.to_i)
		times = [times.to_i, 25].min
		word = first_char + "OL" * times
		if decimal
			word += "O-"
		end
		say(source, word)
	end

	# Laugh from 2-3 times. 10% of the time it will append an extra "O-" as if
	# cut off in the middle of its laughing.
	def laugh_random(source)
		return unless rand < 0.2
		return unless @cooldown.ready_now?
		reps = rand(2)+1
		reps += 0.5 if rand(10) == 1
		laugh(source, reps, nil)
	end
end

