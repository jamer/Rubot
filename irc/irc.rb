
require 'socket'

# The IRCBot class, which represents one connection to a server.
class IRCBot

	# Lets create our IRC commands
	{
		:login => "USER %s %s %s :%s",
		:umode => "MODE %s",
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
	attr_reader :id, :server, :nick, :channels
	attr_accessor :log_input, :log_output
	attr_accessor :raw_listeners, :privmsg_listeners

	def initialize(id, server, port, nick, username, realname)
		@id = id
		@server = server
		@port = port
		@nick = nick
		@username = username
		@realname = realname
		@channels = Array.new

		@log_input = @log_output = true

		@raw_listeners = Array.new
		@privmsg_listeners = Array.new

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
		# Disconnects from the server. The IRCBot is left running.
		return if @disconnected
		@disconnected = true
		quit
		@socket.close
	end

	def destroy
		# Destroys this IRCBot and frees the resources it was using.
		disconnect
		Bots.delete self
	end

	def msg(m)
		# Send a message to the IRC server and print it to the screen
		log "--> #{m}" if @log_output
		@socket.write "#{m}\r\n"
	end

	def say(recipient, message, action = :privmsg)
		raise "No recipient" if recipient.nil?

		return if message == ""

		if message.is_a? Array
			message.each do |piece|
				say recipient, piece, action
			end
			return
		end

		message.each_line do |line|
			send action, recipient, message
		end
		return nil
	end

	def join(channel)
		msg "JOIN #{channel}"
		@channels << channel
	end

	def part(channel)
		msg "PART #{channel}"
		@channels.delete channel
	end

	def add_plugin(id)
		if @plugins.include? id
			raise "Plugin #{id} already loaded in bot #{id}"
		end
		Sources.load "plugins/" + id.to_s + ".rb"
		plugin = Kernel.const_get(id).new
		plugin.attach self
		@plugins[id] = plugin
	end

	def remove_plugin(id)
		if not @plugins.include? id
			raise "Plugin #{id} not loaded in bot #{id}"
		end
		plugin = @plugins[id]
		plugin.detach
		@plugins.delete id
	end

	def add_listener(listener)
		@raw_listeners << listener
	end

	def add_privmsg_listener(listener)
		@privmsg_listeners << listener
	end

	def remove_listener(listener)
		@raw_listeners.delete(listener)
	end

	def remove_privmsg_listener(listener)
		@privmsg_listeners.delete(listener)
	end

	def dead?
		dead = false
		dead = true if @channels.empty?
		dead = true if @raw_listeners.empty? and @privmsg_listeners.empty?
		return dead
	end

	def server_input(s)
		log "<-- #{s}" if @log_input

		case s.strip
		when /^PING :(.+)$/i
			pong $1
		when /^:(\S+?)!(\S+?)@(\S+?)\sPRIVMSG\s(\S+?)\s:(.+)/i
			nick = $1
			realname = $2
			host = $3
			source = $4
			message = $5.strip

			# Somebody is private messaging us.
			if source == @nick
				source = nick
			end

			handle_privmsg nick, realname, host, source, message
		end
	end

	def handle_privmsg(nick, realname, host, source, message)
		handled = false
		@privmsg_listeners.each do |listener|
			if not handled
				handled = listener.call nick, realname, host, source, message
			end 
		end
	end

end

