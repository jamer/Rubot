# Rubot
# A simple, pluggable IRC bot framework.

require 'yaml'

Inputs = 0
Outputs = 1
Errors = 2

class Rubot
	def initialize config_files
		config_files.each do |file|
			load_config_file file
		end

	end

	def load_config_file file
		puts "Init config #{file}"
		yaml = YAML::load_file(file)

		props = %w(address port nick username realname).map { |key| yaml[key] }
		client = Clients::new *props

		yaml["plugins"].each do |plugin|
			client.add_plugin plugin
		end
		yaml["channels"].each do |channel|
			client.join "##{channel}"
		end
	end

	def evaluate s
		begin
			return eval(s).to_s
		rescue Exception => detail
			return detail.message
		end
		return "Error"
	end

	def handle_input
		# Just keep on trucking until we disconnect
		while true
			if Clients::empty?
				puts "Clients list empty, quitting"
				Process::exit
			end
			ready = select([STDIN, *Clients::sockets.keys], nil, nil, nil)
			next if !ready
			ready[Inputs].each { |sock| handle_socket sock }
		end
	end

	def handle_socket sock
		if sock.eof
			puts "Socket #{sock.to_s} reached EOF, quitting"
			Process::exit
		end
		line = sock.gets
		if sock == STDIN then
			puts evaluate line
		else
			client = Clients::sockets[sock]
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
		rescue SystemExit
		rescue Exception => detail
			puts "Exception caught - #{detail.class}(\"#{detail.message}\")"
			puts detail.backtrace.join "\n"
			puts
			retry
		end
	end

end

