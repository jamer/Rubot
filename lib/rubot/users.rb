# FIXME: each IRC network needs its own Users or a User object needs to store its network
# Right now Users is a global variable shared amongst all IRCClient's.

require 'lib/icase-hash.rb'

Users = IgnoreCaseHash.new
Users.set_default_value do |nick|
	User.new(nick)
end
