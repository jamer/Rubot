class Channel
	attr_reader :name
	attr_accessor :users, :new_users

	def initialize(name)
		@name = name
		@new_users = Hash.new
	end
end

