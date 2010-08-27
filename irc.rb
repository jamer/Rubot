
# The IRC class, which talks to the server and holds the main event loop
class IRC

	def initialize(host, server, port, nick, realname, channel, handler)
		@host = host
		@server = server
		@port = port
		@nick = nick
		@realname = realname
		@channel = channel
		@custom_responce_handler = handler

		@log_input = false
		@log_output = false
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
		log "--> #{m}" if @log_output
		@socket.send "#{m}\n", 0
	end

	def privmsg(message, recipient = @channel)
		msg "PRIVMSG #{recipient} :#{message} "
	end

	def action(message, recipient = @channel)
		say "\001ACTION #{message}\001"
	end

	def notice(message, recipient = @channel)
		msg "NOTICE #{recipient} :#{message} "
	end

	def say(message, recipient = @channel, action = :privmsg)
		return if message == ""
		if message.is_a? Array
			say_each message, recipient, action
			return
		end

		recipient = @channel if recipient.nil?
		message.each_line do |line|
			send action, message, recipient
		end
		return nil
	end

	def say_each(list, recipient = @channel, action = :privmsg)
		list.each do |item|
			say item, recipient
		end
	end

	def evaluate(s)
		begin
			return eval(s).to_s
		rescue Exception => detail
			return detail.message
		end
		return "Error"
	end

	def main_loop()
		# Just keep on trucking until we disconnect
		while true
			ready = select([@socket, $stdin], nil, nil, nil)
			next if !ready
			for s in ready[0]
        return if s.eof
        line = s.gets
				if s == $stdin then
					puts evaluate line
				elsif s == @socket then
					server_input line
				end
			end
		end
	end

	def server_input(s)
		log "<-- #{s}" if @log_input

		case s.strip
		when /^PING :(.+)$/i
			msg "PONG :#{$1}"
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
		case message
=begin
		when /^do (.+)/i
			string = $1
			resource
			log "EVAL #{string} from #{nick}!#{realname}@#{host}"
			say evaluate(string), source
=end
		when /^>\s*update/i
			responces = Sources.update ? @@update_yes : @@update_no
			say responces.random
		when /^>(.+)/i
			command = $1.strip
			Sources.update
			@custom_responce_handler.send :user_message, nick, command
		end
	end

	@@update_yes = [
		"Updated.",
		"Now up to date.",
		"Ahh! I missed that update. Thanks for noticing.",
	]

	@@update_no = [
		"Already at latest revision.",
		"Already up to date.",
		"Nothing new worth reporting, sir.",
		"Don't touch me, I'm perfect.",
	]

end


