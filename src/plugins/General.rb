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

	def initialize
		super
	end

	def on_privmsg(user, source, line)
		RegexJump::jump(@@actions, self, line, [user, source])
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

	def rejoin(user, source, channels)
		when_identified(user, proc {
			split_channels(channels).each do |channel|
				if user.privilege(channel) < ChannelOp
					say(source, "Must be channel op.")
					next
				end
				next unless @client.channels.include?(channel)
				@client.channels[channel].rejoin = true
				say(source, "rejoin #{channel} ON")
			end
		})
	end

	def norejoin(user, source, channels)
		when_identified(user, proc {
			split_channels(channels).each do |channel|
				if user.privilege(channel) < ChannelOp
					say(source, "Must be channel op.")
					next
				end
				next unless @client.channels.include?(channel)
				@client.channels[channel].rejoin = false
				say(source, "rejoin #{channel} OFF")
			end
		})
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

