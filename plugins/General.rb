# General use IRC bot

class General < RoobotPlugin

	def privmsg_listener(nick, realname, host, source, message)
		if message =~ /^:(.+)/i
			command = $1.strip
			Sources.update
			return general_command source, nick, command
		end
		return false
	end

	@@actions = {
		:join => /^join (#.+)$/i,
		:part => /^part (#.+)$/i,
		:part_this => /^part (#.+)$/i,

		:speak => /^say (.+)/i,
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
		say source, message
	end

end

