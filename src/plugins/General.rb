# General use IRC bot

class General < RubotPlugin

	@@privmsg_actions = {
		/^:join (#.+)/i => :join,
		/^:part (#.+)/i => :part,
		/^:leave (#.+)/i => :part,
		/^:part$/i => :part_this,
		/^:leave$/i => :part_this,

		/^tell (\S+) (.+)/i => :speak_to,
		/^say (.+)/i => :speak,
	}

	def privmsg(user, source, message)
		@source = source

		al = ActionList.new @@privmsg_actions, self
		return al.parse(message, [source]) do
			log "GENERAL #{user.nick} issued command \"#{command}\""
		end
	end

	def join(source, channel)
		@client.join channel
	end

	def part(source, channel)
		@client.part channel
	end

	def part_this(source)
		@client.part source
	end

	def speak(source, message)
		say source, message.proper_grammar!
	end

	def speak_to(source, target, message)
		say target, message.proper_grammar!
	end

	@@raw_actions = {
		/^INVITE \S+ :(#.+)/i => :invite
	}

	def raw(user, message)
		al = ActionList.new @@raw_actions, self
		return al.parse(message, [user]) do
			log "GENERAL #{nick} issued command \"#{command}\""
		end
	end

	def invite(user, channel)
		@client.join channel
	end

end

