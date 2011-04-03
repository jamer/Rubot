
ChannelEveryone = 0
ChannelVoice = 1
ChannelHalfop = 2
ChannelOp = 3
ChannelAdmin = 4
ChannelFounder = 5

class User
	attr_accessor :nick, :user_name, :host
	attr_reader :presences

	def initialize(nick)
		@nick = nick
		@presences = Hash.new
	end

	def set_presence(channel, sigil)
		privilege = case sigil
		when "+" then ChannelVoice
		when "%" then ChannelHalfop
		when "@" then ChannelOp
		when "&" then ChannelAdmin
		when "~" then ChannelFounder
		else ChannelEveryone
		end

		@presences[channel] = privilege
	end

	def to_s
		if @user_name and @host
			return "#{@nick}!#{@user_name}@#{@host}"
		else
			return "#{nick}"
		end
	end

	def eql?(user)
		user.is_a? User and user.nick == nick
	end
end

