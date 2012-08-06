Users = Hash.new do |hash, nick|
	hash[nick] = User.new(nick)
end
