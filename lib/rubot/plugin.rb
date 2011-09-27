# Base class that all plugins for Rubot must extend. Contains convenience
# methods and adds handy functionality.
class RubotPlugin
	attr_accessor :client

	def initialize
		# List of (User, Proc) that holds callbacks to be launched when the
		# specified user is WHOISed.
		@whois_cbs = Array.new
	end

	# Run any events stored we had stored from a RubotPlugin#when_identified call.
	def on_whois(user)
		return if @whois_cbs.empty?
		@whois_cbs.select {|u, cb| u == user}.each do |nick, cb|
			cb.call
		end
		@whois_cbs.reject! {|u, cb| u == user}
	end

	# Convenience method for saying something.
	def say(recipient, message, action = :privmsg)
		@client.say(recipient, message, action)
	end

	# Convenience method that runs a block once the user is identified. If the
	# user is identified at the time of the call, the block is run immediately.
	# Otherwise it is stored away and a WHOIS request is sent off to the server.
	# This method does not block.
	def on_identification(user, &block)
		if user.registered
			block.call
		else
			@whois_cbs << [user, block]
			@client.whois(user.nick)
		end
	end

	# Splits a string that contains a list of comma-separated channels. Pound
	# signs are prefixed to each channel if necessary, and 0-length channel
	# names are removed.
	def split_channels(channels)
		channels = channels.to_s if channels.is_a?(Integer)
		return channels.split(',').map { |channel|
			channel.strip!
			channel = '#' + channel if channel.size > 0 and channel[0,1] != '#'
			(channel.empty?) ? nil : channel
		}.compact
	end
end

