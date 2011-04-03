
class Clients
	@clients ||= Array.new
	@sockets ||= Hash.new

	class << self
		attr_reader :sockets

		def [](idx)
			return @clients[idx]
		end

		def new(server, port, nick, username, realname)
			client = IRCClient.new server, port, nick, username, realname
			client.connect
			@clients.push client
			@sockets[client.socket] = client
			return client
		end

		def delete(c)
			case c
			when Fixnum
				delete_client @clients[c]
			when IRCClient
				delete_client c
			else
				raise "Not a client or client id"
			end
		end

		def delete_client(client)
			@clients.delete client
			@sockets.delete client.socket
			client.disconnect
		end

		def empty?
			return @clients.empty?
		end

	end
end

