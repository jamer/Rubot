
class UserId
	attr_accessor :nick, :name, :host
	attr_accessor :user

	def initialize(nick, name, host)
		@nick = nick
		@name = name
		@host = host
	end

	def to_s
		return "#{nick}!#{name}#{host}"
	end

	def eql?(id)
		id.is_a? UserId and id.to_s == to_s
	end

	def hash
		to_s.hash
	end
end

class User
	attr_reader :id, :seen_as

	def initialize(id)
		@seen_as = Array.new
		self.id = id
	end

	def id=(id)
		@id = id
		@seen_as << id
	end

	def nick
		return @id.nick
	end

	def name
		return @id.name
	end

	def host
		return @id.host
	end

end

