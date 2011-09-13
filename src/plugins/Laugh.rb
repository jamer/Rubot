class Laugh < RubotPlugin
	# Laugh at command.
	#
	# Says "LOL" when someone types "laugh 1"
	# Says "LOLO-" when someone types "laugh 1.5"
	# Says "LOLOL" when someone types "laugh 2"
	# Etc.

	@@actions = {
		/laugh\s*(\d+\.?\d?)/i => :laugh,
	}

	def on_privmsg(user, source, line)
		return RegexJump::jump(@@actions, self, line, [source])
	end

	# Say "WOLOL" about 10% of the time.
	def first_char
		return rand(10) == 1 ? "W" : "L"
	end

	# Laugh "times" times. If times is a partial decimal, add an extra "O-"
	# to the end of it. Maximum number of times 25 (plus the O- if we're a
	# decimal).
	def laugh(source, times)
		decimal = (times.to_f != times.to_i)
		times = [times.to_i, 25].min
		word = first_char + "OL" * times
		if decimal
			word += "O-"
		end
		say(source, word)
	end
end

