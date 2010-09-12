# Rubot
# A simple, pluggable IRC bot framework.

class Rubot
	@SERVER = "irc.omegadev.org"
	@PORT = 6667

	@NICK = "Apprentice"
	@USERNAME = "apprentice"
	@REALNAME = "Library Apprentice"
	@HOST = "localhost"
	@CHANNEL = "#lib"

	# Open the singleton.
	class << self

		def init
			main = Clients::new :main, @SERVER, @PORT, @NICK, @USERNAME, @REALNAME
			main.add_plugins [:General, :Eval, :UpdateCmd]
			main.add_plugins [:Say, :Bash, :Qdb, :Librarian]
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
			sockets = Clients::sockets
			while true
				ready = select(sockets.keys, nil, nil, nil)
				next if !ready
				for s in ready[0]
					return if s.eof
					line = s.gets
					if s == $stdin then
						puts evaluate line
					else
						id = sockets[s]
						client = Clients[id]
						client.server_input line.strip
						client.destroy if client.dead?
					end
				end
				Process::exit if Clients::empty?
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
end

