class Users
	@users ||= Hash.new
	class << self
		def include?(nick)
			return @users.include? nick
		end

		def get(nick, name, host)
			return nil if nick.nil?
			id = UserId.new nick, name, host
			if @users.include? id
				user = @users[id]
			else
				user = User.new id
				@users[id] = user
			end
			return user
		end
	end
end

