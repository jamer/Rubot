require 'socket'
require 'openssl'

require 'rubygems'
require 'andand'

# Implementation of the bare IRC protocol. There is very little logic in this
# class. It simply abstracts the textual and networked properties of the IRC
# protocol.
class IRCSocket
	# Lets create our IRC commands
	{
		:login => "USER %s %s %s :%s",
		:umode => "MODE %s %s",
		:nickname => "NICK %s",

		:privmsg => "PRIVMSG %s :%s",
		:action => "PRIVMSG %s :\001ACTION %s\001",
		:notice => "NOTICE %s :%s",

		:quit => "QUIT",
	}.each do |command, message|
		define_method(command) do |*args|
			write(message % args) if @connected
		end
	end

	attr_reader :server, :port
	attr_accessor :log_input, :log_output

	def initialize(server, port)
		@server = server
		@port = port
		@log_input = @log_output = true
		@listeners = Array.new
		@connected = false
	end

	def connect
		# Connect to the IRC server. First try using SSL, then fall back to a
		# regular TCP connection.
		tcp = TCPSocket.open(@server, @port)
		ssl = OpenSSL::SSL::SSLSocket.new(tcp)
		begin
			ssl.connect
			@socket = ssl
		rescue
			tcp = TCPSocket.open(@server, @port)
			@socket = tcp
		end
		@connected = true
	end

	def add_listener(obj)
		@listeners << obj
	end

	def emit(sym, *params)
		@listeners.each do |obj|
			obj.send(sym, *params) if obj.respond_to?(sym)
		end
	end

	def write(line)
		# Send a line to the IRC server.
		log("--> #{line}") if @log_output
		@socket.write("#{line}\r\n")
	end

	def peek
		read, write, error = select([@socket], nil, nil, 0)
		return read != nil
	end

	def readline
		if @socket.eof
			@connected = false
			@socket.close
		else
			line = @socket.gets.chomp
			log("<-- #{line}") if @log_input
			process_line(line)
		end
	end

	@@inputs = {
		/^PRIVMSG (\S+) :(.+)/i => :privmsg_input,
		/^353 \S+ = (#\S+) :(.+)/ => :names_list,
		/^366 \S+ (#\S+)/ => :end_of_names_list,
		/^JOIN :?(.+)/i => :user_join,
		/^PART :?(.+)/i => :user_part,
		/^NICK :?(.+)/i => :user_changed_nick,
		/^KICK (\S+) (\S+) :?(\S+)/i => :user_kicked,
	}

	def process_line(line)
		# Handle pings.
		if line =~ /^PING :(.+)/i
			write("PONG #{$1}")
			return
		end

		# Scrape the user.
		nick, username, host = line.scrape!(/^:(\S+?)!(\S+?)@(\S+?)\s+/)
		if nick
			user = Users[nick]
			user.user_name = username
			user.host = host
			base_args = [user]
		else
			base_args = []
		end

		# Scrape the server.
		server = line.scrape!(/^:(\S+) /)

		sym, args = RegexJump::get_jump(@@inputs, line, base_args)
		if sym
			emit(sym, *args)
		else
			# Unhandled line...
		end
	end

	def connected?
		return @connected
	end

	def join(channel)
		raise "invalid channel name" unless channel[0,1] == "#"
		write("JOIN #{channel}")
	end

	def part(channel)
		raise "invalid channel name" unless channel[0,1] == "#"
		write("PART #{channel}")
	end

	def quit
		# Disconnect from the server.
		raise "already disconnected" unless @connected
		write("QUIT")
		@connected = false
		@socket.close
	end
end

