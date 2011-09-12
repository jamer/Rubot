# Rubot
# A simple, pluggable IRC bot framework.

require 'yaml'

class Rubot
	def initialize(config_files)
		@sockets = []

		abort "no config files specified on command line" if config_files.empty?
		config_files.each do |file|
			load_config_file(file)
		end
	end

	def load_config_file(file)
		puts "Init config #{file}"
		yaml = YAML::load_file(file)

		address = yaml["address"]
		port = yaml["port"]

		nick = yaml["nick"]
		username = yaml["username"]
		realname = yaml["realname"]

		plugins = yaml["plugins"]
		channels = yaml["channels"]

		abort "No plugins found in config" if plugins.empty?
		abort "No channels found in config" if channels.empty?

		socket = IRCSocket.new(address, port)
		client = IRCClient.new(socket, nick, username, realname)
		client.connect
		plugins.each {|plugin| client.add_plugin(plugin) }
		channels.each {|channel| client.join("##{channel}") }
		@sockets << socket
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
			puts detail.backtrace.join("\n")
			puts
			retry
		end
	end

	def handle_input
		# Just keep on trucking until we disconnect
		while sleep(0.01)
			@sockets = @sockets.find_all {|socket| socket.connected? }
			abort "Clients list empty, quitting" if @sockets.empty?
			@sockets.each do |socket|
				socket.readline while (socket.connected? and socket.peek)
			end
		end
	end
end

