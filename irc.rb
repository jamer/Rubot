
class IRCUser
	def initialize(nick, realname, host)
	end
end


# The IRC class, which talks to the server and holds the main event loop
class IRC

	@@log_input = false
	@@log_output = false

	def initialize(host, server, port, nick, realname, channel, handler)
		@host = host
		@server = server
		@port = port
		@nick = nick
		@realname = realname
		@channel = channel
		@user_handler = handler
	end

	def connect()
		# Connect to the IRC server
		@socket = TCPSocket.open @server, @port
		[
			"USER #{@nick} #{@server} #{@host} :#{@realname}",
			"NICK #{@nick}",
			"MODE #{@nick} +B",
			"JOIN #{@channel}"
		].each do |line|
			msg line
		end
	end

	def msg(m)
		# Send a message to the IRC server and print it to the screen
		if @@log_output
			log "--> #{m}"
		end
		@socket.send "#{m}\n", 0
	end

	def channel_msg(msg, channel = @channel)
		if msg.is_a? String
			if msg.include? "\n"
				lines = msg.split "\n"
				lines.each do |line|
					channel_msg line, channel
				end
				return
			elsif msg == ""
				return
			end
		elsif msg.respond_to? :each
			msg.each do |item|
				channel_msg item, channel
			end
		end

		msg "PRIVMSG #{channel} :#{msg}"
		return nil
	end

	def action(msg, channel = @channel)
		channel_msg "\001ACTION #{msg}\001"
	end

	def evaluate(s)
		# Make sure we have a valid expression (for security reasons), and
		# evaluate it if we do, otherwise return an error message
#		if s =~ /^[-+*\/\d\s\eE.()]*$/ then
			begin
				return eval(s).to_s
			rescue Exception => detail
				puts detail.message
			end
#		end
		return "Error"
	end

	def main_loop()
		# Just keep on truckin' until we disconnect
		while true
			ready = select([@socket, $stdin], nil, nil, nil)
			next if !ready
			for s in ready[0]
				if s == $stdin then
					return if s.eof
					line = s.gets
					puts evaluate line
				elsif s == @socket then
					return if s.eof
					line = s.gets
					handle_server_input line
				end
			end
		end
	end

	def handle_server_input(s)
		if @@log_input
			log "<-- #{s}"
		end

		case s.strip
		when /^PING :(.+)$/i
			log "Server ping"
			msg "PONG :#{$1}"
		when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s(.+?)\s:(.+)/i
			nick = $1
			realname = $2
			host = $3
			channel = $4
			message = $5.strip
			handle_privmsg nick, realname, host, channel, message
		else
			puts s
		end
	end

	def handle_privmsg(nick, realname, host, channel, message)
		case message
=begin
		when /^do (.+)/i
			string = $1
			resource
			log "EVAL #{string} from #{nick}!#{realname}@#{host}"
			channel_msg evaluate string
=end
		when /^>\s*update/i
			resource
		when /^>(.+)/i
			command = $1.strip
			resource
			@user_handler.send :user_message, nick, command
		end
	end

end


