
# The IRCBot class, which represents one connection to a server.
class IRCBot
	attr_reader :socket

	# Lets create our IRC commands
	{
		:login => "USER %s %s %s :%s",
		:nick => "NICK %s",
		:umode => "MODE %s",

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

	def initialize(id, host, server, port, nick, realname)
		@id = id
		@host = host
		@server = server
		@port = port
		@nick = nick
		@realname = realname
		@channels = Array.new

		@log_input = false
		@log_output = false

		@raw_listeners = Array.new
		@privmsg_listeners = Array.new
	end

	def connect
		# Connect to the IRC server
		@socket = TCPSocket.open @server, @port
		login @nick, @server, @host, @realname
		nick @nick
		umode @nick, "+B"
	end

	def disconnect
		quit
	end

	def msg(m)
		# Send a message to the IRC server and print it to the screen
		log "--> #{m}" if @log_output
		@socket.puts "#{m}", 0
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

			respond_to nick, realname, host, source, message
		end
	end

	def respond_to(nick, realname, host, source, message)
		handled = false
		@privmsg_listeners.each do |listener|
			if not handled
				handled = listener.call nick, realname, host, source, message
			end 
		end
	end

end

