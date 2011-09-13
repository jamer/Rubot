# General use IRC bot
class General < RubotPlugin
	@@actions = {
		/^:join (.+)/i => :join,
		/^:part (.+)/i => :part,
		/^:leave (.+)/i => :part,
		/^:part$/i => :part_this,
		/^:leave$/i => :part_this,
	}

	def privmsg(user, source, line)
		return RegexJump::jump(@@actions, self, line, [source])
	end

	def join(source, channels)
		channels = channels.to_s if channels.is_a?(Integer)
		channels.split(",").each do |channel|
			next if channel.empty?
			channel = "#" + channel unless channel[0,1] == "#"
			@client.join(channel)
		end
	end

	def part(source, channels)
		channels = channels.to_s if channels.is_a?(Integer)
		channels.split(",").each do |channel|
			next if channel.empty?
			channel = "#" + channel unless channel[0,1] == "#"
			@client.part(channel)
		end
	end

	def part_this(source)
		@client.part(source)
	end

	def invite(user, channel)
		@client.join(channel)
	end
end

