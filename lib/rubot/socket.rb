require 'socket'
require 'openssl'

# Semantic class only. Shows that subclasses listen to an IRCSocket.
class IRCSocketListener
end

# Implementation of the bare IRC protocol. There is very little logic in this
# class. It simply abstracts the textual and networked properties of the IRC
# protocol.
class IRCSocket
	attr_reader :host, :port
	attr_accessor :log_input, :log_output

	def initialize(host, port)
		@host = host
		@port = port
		@log_input = @log_output = true
		@connected = false
		@listeners = Array.new
		@last_active = Time.now
	end

	# Connect to the IRC server. First try using SSL, then fall back to a
	# regular TCP connection.
	def connect
		tcp = TCPSocket.new(@host, @port)
		ssl = OpenSSL::SSL::SSLSocket.new(tcp)
		begin
			ssl.connect
			@socket = ssl
		rescue
			tcp = TCPSocket.new(@host, @port)
			@socket = tcp
		end
		@connected = true
	end

	def add_listener(obj)
		@listeners << obj
	end

	def connected?
		return @connected
	end

	def peek
		read, write, error = select([@socket], nil, nil, 0)
		if read
			@last_active = Time.now
		else
			emit(:handle_network_idle, (Time.now - @last_active).to_i)
		end
		return read != nil
	end

	def readline
		if @socket.eof
			@connected = false
			@socket.close
		else
			buf = @socket.readpartial(1024*1024)
			buf.split($/).each do |line|
				line.chomp!
				log("<-- #{line}") if @log_input
				process_line(line)
			end
		end
	end

	# Lets create our IRC commands
	{
		:login => "USER %s %s %s :%s",
		:umode => "MODE %s %s",
		:nickname => "NICK %s",

		:privmsg => "PRIVMSG %s :%s",
		:action => "PRIVMSG %s :\001ACTION %s\001",
		:notice => "NOTICE %s :%s",

		:who => "WHO *",
		:whois => "WHOIS %s",
	}.each do |command, message|
		define_method(command) do |*args|
			write(message % args) if @connected
		end
	end

	def join(channel)
		raise "invalid channel name" unless channel[0,1] == '#'
		raise "invalid channel name" if channel.include?(',')
		write("JOIN #{channel}")
	end

	def part(channel)
		raise "invalid channel name" unless channel[0,1] == '#'
		raise "invalid channel name" if channel.include?(',')
		write("PART #{channel}")
	end

	# Disconnect from the server.
	def quit
		quit_msg("")
	end

	# Disconnect from the server.
	def quit_msg(msg)
		raise "already disconnected" unless @connected
		write("QUIT #{msg}")
		@connected = false
		@socket.close
	end

private
	def emit(sym, *params)
		@listeners.each do |obj|
			obj.send(sym, *params) if obj.respond_to?(sym)
		end
	end

	# Send a line to the IRC server.
	def write(line)
		log("--> #{line}") if @log_output
		@socket.write("#{line}\r\n")
	end

	@@inputs = {
		/^PRIVMSG (\S+) :(.+)/i => :handle_privmsg,
		/^JOIN :(#\S+)/i => :handle_someone_joined,
		/^PART (#\S+)/i => :handle_someone_parted,
		/^NICK :?(.+)/i => :handle_someone_changed_nick,
		/^KICK (\S+) (\S+) :?(\S+)/i => :handle_someone_kicked,
		/^INVITE \S+ :(#\S+)/i => :handle_invite,

		/^001/ => :handle_welcome,

		/^353 \S+ = (#\S+) :(.+)/ => :handle_names_list,
		/^366 \S+ (#\S+)/ => :handle_names_list_end,

		#         chan  user  host  srv nick  umode ??  real
		/^352 \S+ (\S+) (\S+) (\S+) \S+ (\S+) (\S+) :\d+ (.+)$/ => :handle_who,
		/^315/ => :handle_who_end,

		#         nick  user  host     real
		/^311 \S+ (\S+) (\S+) (\S+) \* :(.+)$/ => :handle_whois_user,
		/^307 \S+ (\S+)/ => :handle_whois_registered,
		/^319 \S+ (\S+) :(.*)/ => :handle_whois_channels,
		/^318/ => :handle_whois_end,

		/^433/ => :handle_nickname_in_use,
	}

	# Handle fatal errors from the server.
	def process_line(line)
		if line =~ /^ERROR/
			@connected = false
			@socket.close
			return
		end

		# Handle pings.
		if line =~ /^PING(.*)/i
			write("PONG#{$1}")
			return
		end

		# Scrape the user.
		nick, username, host = line.scrape!(/^:(\S+?)!(\S+?)@(\S+?)\s+/)
		if nick
			user = Users[nick]
			user.username = username
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
end

