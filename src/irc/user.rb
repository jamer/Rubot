ChannelEveryone = 0
ChannelVoice = 1
ChannelHalfop = 2
ChannelOp = 3
ChannelAdmin = 4
ChannelFounder = 5

class User
	attr_accessor :nick, :username, :host
	attr_accessor :registered

	def initialize(nick)
		@nick = nick
		@presences = Hash.new
		@registered = false
	end

	def nick=(n)
		Users::delete(@nick)
		@nick = n
		Users[n] = self
	end

	def sigil2privilege(sigil)
		privilege = case sigil
		when "+" then ChannelVoice
		when "%" then ChannelHalfop
		when "@" then ChannelOp
		when "&" then ChannelAdmin
		when "~" then ChannelFounder
		else ChannelEveryone
		end
	end

	def add_presence(channel)
		@presences[channel] = ChannelEveryone
	end

	def add_presence_as(channel, sigil)
		@presences[channel] = sigil2privilege(sigil)
	end

	def remove_presence(channel)
		@presences.delete(channel)
		if @presences.size == 0
			Users::delete(nick)
		end
	end

	def to_s
		if @username and @host
			return "#{@nick}!#{@username}@#{@host}"
		else
			return "#{nick}"
		end
	end

	def eql?(user)
		user.is_a?(User) and user.nick == nick
	end
end

