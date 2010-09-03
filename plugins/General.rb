# General use IRC bot

class General < RoobotPlugin

	def privmsg_listener(nick, realname, host, source, message)
		var = general_command source, nick, message
		return var
	end

	@@actions = {
		/^:join (#.+)/i => :join,
		/^:part (#.+)/i => :part,
		/^:leave (#.+)/i => :part,
		/^:part$/i => :part_this,
		/^:leave$/i => :part_this,

		/^tell (\S+) (.+)/i => :speak_to,
		/^say (.+)/i => :speak,
	}

	def general_command(source, nick, command)
		@source = source

		al = ActionList.new(@@actions, self)
		return al.parse(command, [source]) do
			log "GENERAL #{nick} issued command \"#{command}\""
		end
	end

	def join(source, channel)
		@bot.join channel
	end

	def part(source, channel)
		@bot.part channel
	end

	def part_this(source)
		@bot.part source
	end

	def speak(source, message)
		say source, message.proper_grammar!
	end

	def speak_to(source, target, message)
		say target, message.proper_grammar!
	end

end

