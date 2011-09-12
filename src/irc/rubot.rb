# Rubot
# A simple, pluggable IRC bot framework.

require 'yaml'

class Rubot
	def initialize config_files
		abort "no config files specified on command line" if config_files.empty?
		@sockets = []
		config_files.each do |file|
			load_config_file file
		end
	end

	def load_config_file file
		puts "Init config #{file}"
		yaml = YAML::load_file(file)

		address = yaml["address"]
		port = yaml["port"]
		socket = IRCSocket::new(address, port)

		nick = yaml["nick"]
		username = yaml["username"]
		realname = yaml["realname"]
		client = IRCClient.new(socket, nick, username, realname)
		client.connect

		yaml["plugins"].each {|plugin| client.add_plugin(plugin) }
		yaml["channels"].each {|channel| client.join("##{channel}") }

		@sockets << socket
	end

	def handle_input
		# Just keep on trucking until we disconnect
		while true
			@sockets = @sockets.find_all {|socket| socket.connected? }
			if @sockets.empty?
				puts "Clients list empty, quitting"
				return
			end
			@sockets.each do |socket|
				while socket.peek
					socket.readline
				end
			end
			sleep(0.1)
		end
	end

	def main_loop
		# If we get an exception, then print it out and keep going
		# We do NOT want to disconnect unexpectedly!
		begin
			handle_input
		rescue Interrupt
		rescue SystemExit
		rescue Exception => detail
			puts "Exception caught - #{detail.class}(\"#{detail.message}\")"
			puts detail.backtrace.join "\n"
			puts
			retry
		end
	end
end

