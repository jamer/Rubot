class Channel
	attr_reader :name, :rejoin
	attr_accessor :users, :new_users

	def initialize(name)
		@name = name
		@users = Hash.new
		@new_users = Hash.new
		@rejoin = false
	end

	def rejoin=(bool)
		@rejoin = bool
		log "%s rejoin channel #{@name}" % (bool ? "Will" : "Won't")
	end
end

