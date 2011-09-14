class Channel
	attr_reader :name
	attr_accessor :users, :new_users, :rejoin

	def initialize(name)
		@name = name
		@users = Hash.new
		@new_users = Hash.new
		@rejoin = false
	end
end

