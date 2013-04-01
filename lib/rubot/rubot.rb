# Rubot
# A simple, pluggable IRC bot framework.

require 'lib/rubot/client.rb'
require 'lib/rubot/connection.rb'

require 'yaml'

SECOND = 1

class Rubot
	def initialize(config_files)
		abort "No config files specified on command line." if config_files.empty?

		@connections = []
		config_files.each { |f| spawn_client(f) }
	end

	def spawn_client(file)
		yaml = YAML::load_file(file)

		address = yaml["address"]
		port = yaml["port"]

		nick = yaml["nick"]
		username = yaml["username"]
		realname = yaml["realname"]

		channels = yaml["channels"]
		plugins = yaml["plugins"]

		abort "No channels found in config." if channels.nil?
		abort "No plugins found in config." if plugins.nil?

		connection = IRCConnection::new(address, port)
		client = IRCClient::new(connection, nick, username, realname)
		@connections << connection

		# Fire off initial network commands.
		client.connect
		channels.each { |name| client.join("##{name}") }
		plugins.each { |name| client.add_plugin(name) }
	end

	def main_loop
		# If we get an exception, then print it out and keep going
		# We do NOT want to disconnect unexpectedly!
		begin
			select_loop
		rescue Interrupt
			quit_connections("SIGINT")
		rescue SystemExit
		rescue Exception => detail
			puts "Exception caught - #{detail.class}(\"#{detail.message}\")"
			puts detail.backtrace.join("\n")
			puts
			retry
		end
	end

	# Read and handle all open sockets until they all disconnect.
	def select_loop
		while @connections.size > 0
			sockets = @connections.map { |c| c.socket }
			want_idle = @connections.any? { |c| c.want_network_idle? }
			timeout = want_idle ? 1 * SECOND : nil

			rd, wr, err = IO::select(sockets, nil, sockets, timeout)

			if rd && rd.size > 0
				readables = @connections.select { |c| rd.include? c.socket }
				readables.each { |c| c.readlines }
			end

			if err && err.size > 0
				errored = @connections.select { |c| err.include?(c.socket) }
				errored.each do |c|
					puts "rubot.rb: IO::select(): error on #{c.host}, dropping connection"
				end
				@connections = @connections.select { |c| !err.include?(c.socket) }
			end

			@connections = @connections.select { |c| c.connected? }
			@connections.each { |c| c.emit_idle } if want_idle && rd.nil? && err.nil?
		end
		log "No connections left, quitting."
	end

	def quit_connections(msg)
		@connections.each { |c| c.quit(msg) }
		@connections = []
	end
end
