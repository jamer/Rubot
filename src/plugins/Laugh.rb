
class Laugh < RubotPlugin

	@@privmsg_actions = {
		/laugh\s*(\d+\.?\d?)/i => :laugh,
#		/^laughs (\d+)/i => :laughs,
	}

	def privmsg(user, source, message)
		@source = source

		al = ActionList.new @@privmsg_actions, self
		return al.parse(message, [source])
	end

	def first_char
		return rand(10) == 1 ? "W" : "L"
	end

	# Laugh "times" times. If times is a partial decimal, add an extra "O-"
	# to the end of it. Maximum length of laugh is 25 times (plus the O- if
	# we're a decimal).
	def laugh source, times
		times = times.to_s
		jack = times.include? "."
		if jack
			times = times.sub /\..*/, ""
		end
		times = times.to_i
		times = 25 if times > 25
		word = first_char + "OL" * times
		if jack
			word += "O-"
		end
		say source, word
	end

	def laughs source, times
		
	end
end

