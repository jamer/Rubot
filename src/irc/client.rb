
require 'socket'

# Each IRCClient represents one connection to a server.
class IRCClient
	class << self
		attr_accessor :listener_types
	end

	@listener_types = [
		:raw,
		:privmsg,
	]

	# Lets create our IRC commands
	{
		:login => "USER %s %s %s :%s",
		:umode => "MODE %s %s",
		:nickname => "NICK %s",

		:pong => "PONG :%s",

		:privmsg => "PRIVMSG %s :%s",
		:action => "PRIVMSG %s :\001ACTION %s\001",
		:notice => "NOTICE %s :%s",

		:quit => "QUIT",
	}.each do |command, message|
		define_method command do |*args|
			msg message % args
		end
	end

	attr_reader :socket
	attr_reader :nick, :username, :realname
	attr_reader :id, :server, :plugins
	attr_reader :channels, :users
	attr_accessor :log_input, :log_output
	attr_accessor :listeners

	def initialize(id, server, port, nick, username, realname)
		@id = id
		@server = server
		@port = port
		@nick = nick
		@username = username
		@realname = realname

		@channels = Hash.new
		@users = Hash.new

		@log_input = @log_output = false

		@listeners = Hash.new
		self.class.listener_types.each do |type|
			@listeners[type] = Array.new
		end

		@plugins = Hash.new
		@disconnected = false
	end

	def connect
		# Connect to the IRC server
		@socket = TCPSocket.open @server, @port
		nickname @nick
		login @username, "localhost", @server, @realname
		umode @nick, "+B"
	end

	def disconnect
		# Disconnects from the server. The IRCClient is left running.
		return if @disconnected
		@disconnected = true
		quit
		@socket.close
	end

	def destroy
		# Destroys this IRCClient and frees the resources it was using.
		disconnect
		Clients::delete self
	end

	def msg(m)
		# Send a single message to the IRC server.
		log "--> #{m}" if @log_output
		@socket.write "#{m}\r\n"
	end

	def say(recipient, message, action = :privmsg)
		raise "No recipient" if recipient.nil?
		return if message == ""

		case message
		when Array
			message.each do |item|
				say recipient, item, action
			end
		when Hash
			message.each do |key, value|
				say recipient, "#{key} => #{value}", action
			end
		when String
			message.each_line do |line|
				send action, recipient, message
			end
		else
			say recipient, message.to_s, action
		end

		return nil
	end

	def join(name)
		msg "JOIN #{name}"
		channel = Channel.new name
		@channels[name] = channel if not @channels.include? name
	end

	def part(name)
		msg "PART #{name}"
		@channels.delete name
	end

	def add_plugin(id)
		if @plugins.include? id
			raise "Plugin #{id} already loaded in client #{id}"
		end
		Sources.require "src/plugins/" + id.to_s + ".rb"
		plugin = Kernel.const_get(id).new
		plugin.attach self
		@plugins[id] = plugin
	end

	def add_plugins(ids)
		ids.each { |plugin| add_plugin plugin }
	end

	def remove_plugin(id)
		unless @plugins.include? id
			raise "Plugin #{id} not loaded in client #{id}"
		end
		plugin = @plugins[id]
		plugin.detach
		@plugins.delete id
	end

	def remove_plugins(ids)
		id.each { |plugin| remove_plugin plugin }
	end

	def dead?
		dead = false
		dead = true if @channels.empty?
		dead = true if listeners.all? { |type, handlers| handlers.length == 0 }
		return dead
	end

	def emit(signal, *params)
		@listeners[signal].each { |l| l.call *params }
	end

	@@inputs = {
		/^PING :(.+)/i => :ping_input,
		/^PRIVMSG (\S+) :(.+)/i => :privmsg_input,
		/^353 \S+ = (#\S+) :(.+)/ => :names_list,
		/^366 \S+ (#\S+)/ => :end_of_names_list,
		/^JOIN :?(.+)/i => :user_join,
		/^PART :?(.+)/i => :user_part,
		/^NICK :?(.+)/i => :user_changed_nick,
	}

	def server_input(line)
		log "<-- #{line}" if @log_input

		# Scrape the user
		nick, username, host = line.scrape! /^:(\S+?)!(\S+?)@(\S+?)\s/
		if nick
			user = Users[nick]
			user.user_name = username
			user.host = host
			args = [user]
		else
			args = []
		end

		# Scrape the server
		server = line.scrape! /^:(\S+) /

		al = ActionList.new @@inputs, self
		al.parse line, args
		emit :raw, user, line
	end

	def ping_input(noise)
		pong noise
	end

	def privmsg_input(user, target, message)
		private_message = (target == @nick)
		if private_message
			reply_to = user.nick
		else
			reply_to = target
		end
		emit :privmsg, user, reply_to, message.to_s
	end

	def names_list(channel, line_of_names)
		ch = @channels[channel]
		names = line_of_names.split(" ")
		names.each { |name|
			sigil = name.downcase.gsub(/[a-z]/, "")
			name = name.sub(/^[~&@%+]/, "")
			user = Users[name]
			user.set_presence channel, sigil
			ch.new_users[name] = user
		}
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
		user.presences.delete channel
		@channels[channel].users.delete nick
		Users.delete(nick) unless user.presences.size > 0
	end

	def user_changed_nick(user, new)
		# Update user's nickname
		old = user.nick
		user.nick = new

		# Update references to this user
		Users[new] = user
		Users.delete old
		user.presences.each do |channel_name, _|
			channel = @channels[channel_name]
			channel.users[new] = user
			channel.users.delete old
		end
	end
end

