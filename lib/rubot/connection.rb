require 'socket'
require 'openssl'

# Semantic class only. Shows that subclasses listen to an IRCConnection.
class IRCConnectionListener
end

# Implementation of the bare IRC protocol. There is very little logic in this
# class. It simply abstracts the textual and networked properties of the IRC
# protocol.
class IRCConnection
	attr_reader :host, :port, :socket
	attr_accessor :log_input, :log_output

	def initialize(host, port)
		@host = host
		@port = port
		@log_input = @log_output = true
		@log_pings = false
		@connected = false
		@listeners = Array::new
		@last_active = Time::now
		@linebuf_rd, @linebuf_wr = IO.pipe
	end

	def to_s
		return "<IRCConnection object @ #{host}:#{port}>"
	end

	# Connect to the IRC server. First try using SSL, then fall back to a
	# regular TCP connection.
	def connect
		tcp = TCPSocket.new(@host, @port)
		ssl = OpenSSL::SSL::SSLSocket::new(tcp)
		begin
			ssl.connect
			@socket = ssl
		rescue
			tcp = TCPSocket::new(@host, @port)
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

	def want_network_idle?
		return @listeners.any? { |l| l.want_network_idle? }
	end

	def emit_idle
		emit(:handle_network_idle, (Time::now - @last_active).to_i)
	end

	def readlines
		@last_active = Time::now
		if @socket.eof
			@connected = false
			@socket.close
		else
			input = @socket.readpartial(1e6)
			# Pushing data through a pipe preserves any incoming lines that are split
			# across two or more reads.
			@linebuf_wr << input
			input.count("\n").times do
				line = @linebuf_rd.gets.chomp
				is_ping = line.upcase.start_with?("PING")
				log("<-- #{line}") if (@log_pings || !is_ping) && @log_input
				process_line(line)
			end
		end
	end

	# Create our IRC commands
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
	def quit(msg = "")
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
	def write(line, is_ping = false)
		log("--> #{line}") if (@log_pings || !is_ping) && @log_output
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
			write("PONG#{$1}", true)
			return
		end

		# Scrape the user.
		nick, username, host = line.scrape!(/^:(\S+?)!(\S+?)@(\S+?)\s+/)
		if nick
			# FIXME: Don't necessarily add to Users struct if we can't see the user
			# normally.
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
