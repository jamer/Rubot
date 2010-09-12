# Rubot
# A simple, pluggable IRC bot framework.

class Rubot
	def initialize
		@SERVER = "irc.n0v4.org"
		@PORT = 6667

		@NICK = "Gandalph"
		@USERNAME = "wizard"
		@REALNAME = "Gandalph the Grey"
		@HOST = "localhost"
		@CHANNEL = "#libby"

		main = Clients::new :main, @SERVER, @PORT, @NICK, @USERNAME, @REALNAME
		main.add_plugins [:General, :Eval, :UpdateCmd]
		main.add_plugins [:Say, :Weather, :Bash, :Qdb, :Librarian]
		main.join @CHANNEL
	end

	def evaluate(s)
		begin
			return eval(s).to_s
		rescue Exception => detail
			return detail.message
		end
		return "Error"
	end

	def handle_input()
		# Just keep on trucking until we disconnect
		while true
			ready = select(Clients::sockets.keys, nil, nil, nil)
			next if !ready
			ready[0].each { |sock| handle_socket sock }
			Process::exit if Clients::empty?
		end
	end

	def handle_socket(sock)
		Process::exit if sock.eof
		line = sock.gets
		if sock == $stdin then
			puts evaluate line
		else
			id = Clients::sockets[sock]
			client = Clients[id]
			client.server_input line.strip
			client.destroy if client.dead?
		end
	end

	def main_loop
		# If we get an exception, then print it out and keep going
		# We do NOT want to disconnect unexpectedly!
		begin
			handle_input
		rescue Interrupt
		rescue Exception => detail
			puts detail.message
			print detail.backtrace.join "\n"
			retry
		end
	end

end

