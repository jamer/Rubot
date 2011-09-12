# General use IRC bot
class General < RubotPlugin
	@@actions = {
		/^:join (#.+)/i => :join,
		/^:part (#.+)/i => :part,
		/^:leave (#.+)/i => :part,
		/^:part$/i => :part_this,
		/^:leave$/i => :part_this,
	}

	def privmsg(user, source, line)
		return RegexJump::jump(@@actions, self, line, [source])
	end

	def join(source, channel)
		@client.join(channel)
	end

	def part(source, channel)
		@client.part(channel)
	end

	def part_this(source)
		@client.part(source)
	end

	@@raw_handlers = {
		/^INVITE \S+ :(#.+)/i => :invite
	}

	def raw(user, line)
		return RegexJump::jump(@@raw_handlers, self, line, [user])
	end

	def invite(user, channel)
		@client.join(channel)
	end
end

