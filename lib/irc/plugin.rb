class RubotPlugin
	attr_accessor :client

	def initialize
		@whois_cbs = Array.new
	end

	def on_whois(user)
		@whois_cbs.select {|u, cb| u == user}.each do |nick, cb|
			cb.call
		end
		@whois_cbs.reject! {|u, cb| u == user}
	end

	def say(recipient, message, action = :privmsg)
		# Convenience method for saying something.
		@client.say(recipient, message, action)
	end

	def when_identified(user, prok)
		if user.registered
			prok.call
		else
			@whois_cbs << [user, prok]
			@client.whois(user.nick)
		end
	end
end

