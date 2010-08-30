#!/usr/bin/ruby
# Roobot
# A simple, pluggable IRC bot framework.

# Tabs are 2 spaces in length. Set your editor to this.

require 'socket'

require 'sources.rb'
Sources.this_is(__FILE__)
Sources << "actionlist.rb"
Sources << "irc.rb"
Sources << "library.rb"
Sources << "misc.rb"
Sources << "plugin.rb"

run_only_once :defines do
	SERVER = "irc.omegadev.org"
	PORT = 6667

	NICK = "LibAssistant"
	HOST = REALNAME = "localhost"
	CHANNEL = "#lib"
end


class Roobot
	class << self

	def init
		@bots = Hash.new
		@sockets = { $stdin => :keyboard }
		@plugins = Hash.new
		main = create_bot :main, HOST, SERVER, PORT, NICK, REALNAME
		main.join CHANNEL
		add_plugin :General
		add_plugin :Librarian
		add_plugin :Rooval
	end

	def create_bot(id, host, server, port, nick, realname)
		if @bots.include? id
			raise "Bot with id #{id.to_s} already exists."
		end
		bot = IRCBot.new id, host, server, port, nick, realname
		bot.connect
		@bots[id] = bot
		@sockets[bot.socket] = id
		return bot
	end

	def destroy_bot(id)
		bot = @bots[id]
		@bots.delete id
		@sockets.delete bot.socket
		bot.disconnect
	end

	def add_plugin(id)
		Sources << "plugins/" + id.to_s + ".rb"
		plugin = Kernel.const_get(id).new
		plugin.attach(@bots[:main])
		@plugins[id] = plugin
	end

	def remove_plugin(id)
		plugin = @plugins[id]
		plugin.detach
		@plugins.delete[id]
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
			ready = select(@sockets.keys, nil, nil, nil)
			next if !ready
			for s in ready[0]
        return if s.eof
        line = s.gets
				if s == $stdin then
					puts evaluate line
				else
					id = @sockets[s]
					bot = @bots[id]
					bot.server_input line
				end
			end
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

run_only_once :program do
	Roobot.init
	Roobot.main_loop
end

