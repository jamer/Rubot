# Each IRCClient represents one connection to a server.
class IRCClient
	attr_reader :ircsocket
	attr_reader :nick, :username, :realname
	attr_reader :plugins
	attr_reader :channels, :users

	def initialize(ircsocket, nick, username, realname)
		@ircsocket = ircsocket
		@nick = nick
		@username = username
		@realname = realname

		@channels = Hash.new
		@users = Hash.new
		@plugins = Hash.new

		ircsocket.add_listener(self)
	end

	def connect
		# Connect to the IRC server
		@ircsocket.connect
		@ircsocket.nickname(@nick)
		@ircsocket.login(@username, "localhost", @ircsocket.server, @realname)
		@ircsocket.umode(@nick, "+B")
	end

	def say(recipient, message, action = :privmsg)
		raise "No recipient" if recipient.nil?
		return if message == ""

		case message
		when Array
			message.each do |item|
				say(recipient, item, action)
			end
		when Hash
			message.each do |key, value|
				say(recipient, "#{key} => #{value}", action)
			end
		when String
			message.each_line do |line|
				@ircsocket.send(action, recipient, message)
			end
		else
			say(recipient, message.to_s, action)
		end

		return nil
	end

	def join(name)
		@ircsocket.join(name)
		channel = Channel.new(name)
		@channels[name] = channel if not @channels.include?(name)
	end

	def part(name)
		@ircsocket.part(name)
		@channels[name].users.each do |nick, user|
			user_part(user, name)
		end
		@channels.delete(name)
		if @channels.empty?
			@ircsocket.quit
		end
	end

	def add_plugin(id)
		if @plugins.include?(id)
			raise "Plugin #{id} already loaded in client #{id}"
		end
		Sources.require("src/plugins/" + id.to_s + ".rb")
		plugin = Kernel.const_get(id).new
		plugin.client = self
		@plugins[id] = plugin
	end

	def add_plugins(ids)
		ids.each {|plugin| add_plugin(plugin) }
	end

	def remove_plugin(id)
		unless @plugins.include?(id)
			raise "Plugin #{id} not loaded in client #{id}"
		end
		plugin = @plugins[id]
		@plugins.delete(id)
		if @plugins.empty?
			@ircsocket.quit
		end
	end

	def remove_plugins(ids)
		id.each {|plugin| remove_plugin(plugin) }
	end

	def emit(sym, *params)
		@plugins.each do |name, obj|
			obj.send(sym, *params) if obj.respond_to?(sym)
		end
	end

	def privmsg_input(user, target, message)
		private_message = (target == @nick)
		reply_to = private_message ? user.nick : target
		emit(:privmsg, user, reply_to, message.to_s)
	end

	def names_list(channel, line_of_names)
		ch = @channels[channel]
		names = line_of_names.split(" ")
		names.each do |name|
			sigil = name.downcase.gsub(/[a-z]/, "")
			name = name.sub(/^[~&@%+]/, "")
			user = Users[name]
			user.set_presence(channel, sigil)
			ch.new_users[name] = user
		end
	end

	def end_of_names_list(channel)
		ch = @channels[channel]
		ch.users = ch.new_users
		ch.new_users = Hash.new
	end

	def user_join(user, channel)
		user.presences[channel] = ChannelEveryone
		@channels[channel].users[user.nick] = user
	end

	def user_part(user, channel)
		nick = user.nick
		user.presences.delete(channel)
		@channels[channel].users.delete(nick)
		Users.delete(nick) unless user.presences.size > 0
	end

	def user_changed_nick(user, new)
		# Update user's nickname
		old = user.nick
		user.nick = new

		# Update references to this user
		Users[new] = user
		Users.delete(old)
		user.presences.each do |channel_name, _|
			channel = @channels[channel_name]
			channel.users[new] = user
			channel.users.delete(old)
		end
	end

	def user_kicked(src, channel, target, reason)
		user_part(Users[target], channel)

		# If we get kicked
		if target == @nick
			@channels[channel].users.each do |nick, user|
				user_part(user, channel)
			end
			@channels.delete(channel)
			if @channels.empty?
				@ircsocket.quit
			end
		end
	end
end

