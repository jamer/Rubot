
class RubotPlugin

	def attach(client)
		# Attach this plugin to a client. Client will now ask us to handle its
		# various incoming server messages.
		@client = client
		my_listeners.each { |l| client.listeners[l.to_sym].push method l }
	end

	def detach
		# Detatch from a client.
		my_listeners.each { |l| @client.listeners[l.to_sym].delete method l }
	end

	def my_listeners
		return methods.select { |type| @client.listeners.include? type.to_sym }
	end

	def say(recipient, message)
		# Convenience method for saying something.
		@client.say recipient, message
	end

end

