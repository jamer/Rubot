# General use IRC bot

class General < RubotPlugin

	@@privmsg_actions = {
		/^:join (#.+)/i => :join,
		/^:part (#.+)/i => :part,
		/^:leave (#.+)/i => :part,
		/^:part$/i => :part_this,
		/^:leave$/i => :part_this,
	}

	def privmsg(user, source, message)
		@source = source

		al = RegexJump.new @@privmsg_actions, self
		if al.parse(message, [source]) then
			log "GENERAL #{user.nick} issued command \"#{message}\""
			Sources.update
			return true
		else
			return false
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

	@@raw_actions = {
		/^INVITE \S+ :(#.+)/i => :invite
	}

	def raw(user, message)
		al = RegexJump.new @@raw_actions, self
		return al.parse(message, [user])
	end

	def invite(user, channel)
		@client.join channel
	end

end

