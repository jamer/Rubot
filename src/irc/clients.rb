
class Clients
	@clients ||= Hash.new
	@sockets ||= Hash.new

	class << self
		attr_reader :sockets

		def [](id)
			return @clients[id.to_sym]
		end

		def new(id, server, port, nick, username, realname)
			if @clients.include? id
				raise "Client with id #{id} already exists."
			end
			client = IRCClient.new id, server, port, nick, username, realname
			client.connect
			@clients[id] = client
			@sockets[client.socket] = id
			return client
		end

		def delete(c)
			case c
			when Symbol
				delete_client @clients[c]
			when String
				delete_client @clients[c.to_sym]
			when IRCClient
				delete_client c
			else
				raise "Not a client or client id"
			end
		end

		def delete_client(client)
			@clients.delete client.id
			@sockets.delete client.socket
			client.disconnect
		end

		def empty?
			return @clients.empty?
		end

	end
end

