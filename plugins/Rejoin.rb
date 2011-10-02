# Adds commands to control automatic rejoining of channels. There is no
# persistent storage in this plugin, so channels will have to be readded on
# each run.
class Rejoin < RubotPlugin
	@@actions = [
		[/^:rejoin (.+)/i, :rejoin],
		[/^:norejoin (.+)/i, :norejoin],
	]

	def initialize
		super
	end

	def on_privmsg(user, source, msg)
		RegexJump::jump(@@actions, self, msg, [user, source])
	end

	def on_join(user, channel)
		# TODO: Persist channel auto-rejoin status.
	end

	# Enables automatic rejoining for the specified channels.
	def rejoin(user, source, channels)
		on_identification(user) do
			split_channels(channels).each do |channel|
				if user.privilege(channel) < ChannelOp
					say(source, "You must be at least a channel operator on #{channel}.")
				elsif not @client.channels.include?(channel)
					say(source, "I'm not in #{channel}.")
				else
					@client.channels[channel].rejoin = true
					say(source, "rejoin #{channel} ON")
				end
			end
		end
	end

	# Disables automatic rejoining for the specified channels.
	def norejoin(user, source, channels)
		on_identification(user) do
			split_channels(channels).each do |channel|
				if user.privilege(channel) < ChannelOp
					say(source, "You must be at least a channel operator on #{channel}.")
				elsif not @client.channels.include?(channel)
					say(source, "I'm not in #{channel}.")
				else
					@client.channels[channel].rejoin = false
					say(source, "rejoin #{channel} OFF")
				end
			end
		end
	end
end

