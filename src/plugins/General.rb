# General use IRC bot
class General < RubotPlugin
	@@actions = {
		/^:join (.+)/i => :join,
		/^:part (.+)/i => :part,
		/^:leave (.+)/i => :part,
		/^:part$/i => :part_this,
		/^:leave$/i => :part_this,
		/^:rejoin (.+)/i => :rejoin,
		/^:norejoin (.+)/i => :norejoin,
	}

	def on_privmsg(user, source, line)
		return RegexJump::jump(@@actions, self, line, [source])
	end

	def on_invite(user, channel)
		@client.join(channel)
	end

	def join(source, channels)
		split_channels(channels).each do |channel|
			@client.join(channels)
		end
	end

	def part(source, channels)
		split_channels(channels).each do |channel|
			@client.part(channels)
		end
	end

	def part_this(source)
		@client.part(source)
	end

	def rejoin(source, channels)
		split_channels(channels).each do |channel|
			@client.channels[channel].rejoin = true if
					@client.channels.include?(channel)
		end
	end

	def norejoin(source, channels)
		split_channels(channels).each do |channel|
			@client.channels[channel].rejoin = false if
					@client.channels.include?(channel)
		end
	end

	def split_channels(channels)
		channels = channels.to_s if channels.is_a?(Integer)
		return channels.split(',').map { |channel|
			channel.strip!
			channel = '#' + channel if channel.size > 0 and channel[0,1] != '#'
			(channel.empty?) ? nil : channel
		}.compact
	end
end

