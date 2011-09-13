# Each IRCClient represents one connection to a server.
class IRCClient < IRCSocketListener
	attr_reader :nick, :username, :realname
	attr_reader :channels

	def initialize(ircsocket, nick, username, realname)
		@ircsocket = ircsocket
		@nick = nick
		@username = username
		@realname = realname

		@channels = Hash.new
		@plugins = Hash.new
		@whois = Hash.new

		ircsocket.add_listener(self)
	end

	def connect
		# Connect to the IRC server
		@ircsocket.connect
		@ircsocket.nickname(@nick)
		@ircsocket.login(@username, "localhost", @ircsocket.server, @realname)
		@ircsocket.umode(@nick, "+B")
	end

	def add_plugin(name)
		if @plugins.include?(name)
			raise "Plugin #{name} already loaded in client"
		end
		Sources::require("src/plugins/#{name}.rb")
		plugin = Kernel::const_get(name).new
		plugin.client = self
		@plugins[name] = plugin
	end

	def remove_plugin(name)
		if not @plugins.include?(name)
			raise "Plugin #{name} not present in client"
		end
		@plugins.delete(name)
		if @plugins.empty?
			@ircsocket.quit
		end
	end

	def emit(sym, *params)
		@plugins.each do |name, obj|
			obj.send(sym, *params) if obj.respond_to?(sym)
		end
	end

	def say(recipient, message, action = :privmsg)
		# Pretty-print to a channel.
		raise "No recipient" if recipient.nil?
		return nil if message == ""

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
		return if @channels.include?(name)
		@ircsocket.join(name)
		channel = Channel.new(name)
		@channels[name] = channel
	end

	def part(name)
		handle_someone_parted(Users[@nick], name)
	end

	def who
		@ircsocket.who
	end

	def whois(name)
		@ircsocket.whois(name)
	end

	def handle_privmsg(user, target, message)
		private_message = (target == @nick)
		reply_to = private_message ? user.nick : target
		emit(:privmsg, user, reply_to, message.to_s)
	end

	def handle_someone_joined(user, channel)
		user.add_presence(channel)
		@channels[channel].users[user.nick] = user
	end

	def handle_someone_parted(user, channel)
		if user.nick == @nick
			# If we part
			return unless @channels.include?(channel)
			@channels[channel].users.each do |nick, user|
				handle_someone_parted(user, channel) if user.nick != @nick
			end
			@channels.delete(channel)
			if @channels.empty?
				@ircsocket.quit
			end
			@ircsocket.part(channel)
		else
			user.remove_presence(channel)
			@channels[channel].users.delete(user.nick)
		end
	end

	def handle_someone_changed_nick(user, new)
		# Update user's nickname
		old = user.nick
		user.nick = new

		# Update references to this user
		user.presences.each do |channel_name, _|
			channel = @channels[channel_name]
			channel.users[new] = user
			channel.users.delete(old)
		end
	end

	def handle_someone_kicked(src, channel, target, reason)
		handle_someone_parted(Users[target], channel)
	end

	def handle_invite(user, channel)
		# user has invited us to a channel
		emit(:invite, user, channel)
	end

	def handle_names_list(channel, line_of_names)
		ch = @channels[channel]
		names = line_of_names.split(" ")
		names.each do |name|
			sigil = name[0,1]
			sigil = "" if not sigil.match(/[~&@%+]/)
			name = name.sub(/^[~&@%+]/, "")
			user = Users[name]
			user.add_presence_as(channel, sigil)
			ch.new_users[name] = user
		end
	end

	def handle_names_list_end(channel)
		ch = @channels[channel]
		ch.users = ch.new_users
		ch.new_users = Hash.new
	end

	def handle_who(channel, username, host, nick, umode, realname)
		return if channel == "*" # Network services are listed here
		user = Users[nick]
		user.username = username
		user.host = host
		user.add_presence(channel)
		user.registered = true if umode.include?("r")
		emit(:who, user)
	end

	def handle_who_end
		# No-op
	end

	def handle_whois_user(nick, username, host, realname)
		@whois[:nick] = nick
		@whois[:username] = username
		@whois[:host] = host
	end

	def handle_whois_registered(nick)
		@whois[:nick] = nick
		@whois[:registered] = true
	end

	def handle_whois_channels(nick, channels_line)
		@whois[:nick] = nick
		channel_words = channels_line.split
		channels = channel_words.map {|word|
			sigil = word[0,1]
			sigil = "" if not sigil.match(/[~&@%+]/)
			name = word.sub(/^[~&@%+]/, "")
			[name, sigil]
		}
		@whois[:channels] = channels
	end

	def handle_whois_end
		nick = @whois[:nick]
		username = @whois[:username]
		host = @whois[:host]
		registered = @whois[:registered]
		channels = @whois[:channels]

		user = Users[nick]
		user.username = username
		user.host = host
		user.registered = registered if registered
		if channels
			channels.each do |name, sigil|
				user.add_presence_as(name, sigil)
			end
		end

		@whois = Hash.new

		emit(:whois, user)
	end
end

