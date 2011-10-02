# General use IRC bot
class General < RubotPlugin
	@@actions = [
		[/^:join (.+)/i, :join],
		[/^:part (.+)/i, :part],
		[/^:leave (.+)/i, :part],
		[/^:part$/i, :part_this],
		[/^:leave$/i, :part_this],
	]

	def initialize
		super
	end

	def on_privmsg(user, source, msg)
		RegexJump::jump(@@actions, self, msg, [user, source])
	end

	def on_invite(user, channel)
		@client.join(channel)
	end

	def join(user, source, channels)
		split_channels(channels).each do |channel|
			@client.join(channels)
		end
	end

	def part(user, source, channels)
		split_channels(channels).each do |channel|
			@client.part(channels)
		end
	end

	def part_this(user, source)
		@client.part(source)
	end
end

