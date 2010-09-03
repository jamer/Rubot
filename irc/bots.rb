
class Bots
	@bots ||= Hash.new
	@sockets ||= Hash.new

	class << self
		attr_reader :sockets

		def [](id)
			return @bots[id.to_sym]
		end

		def new(id, server, port, nick, username, realname)
			if @bots.include? id
				raise "Bot with id #{id.to_s} already exists."
			end
			bot = IRCBot.new id, server, port, nick, username, realname
			bot.connect
			@bots[id] = bot
			@sockets[bot.socket] = id
			return bot
		end

		def delete(b)
			case b.type
			when Symbol
				delete_bot @bots[b]
			when String
				delete_bot @bots[b.to_sym]
			when IRCBot
				delete_bot b
			else
				raise "Not a bot or id"
			end
		end

		def delete_bot(bot)
			@bots.delete bot.id
			@sockets.delete bot.socket
			bot.disconnect
		end

		def empty?
			return @bots.empty?
		end

	end
end

