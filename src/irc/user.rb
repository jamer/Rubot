class UserId
	attr_accessor :nick, :username, :host

	def initialize(nick, username, host)
		@nick = nick
		@username = username
		@host = host
	end
end
