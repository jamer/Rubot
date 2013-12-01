class SendRaw < RubotPlugin
	@@actions = [
		[/^:send_raw (.+)/i, :send_raw]
	]

	def initialize
		super
	end

	def on_privmsg(user, source, msg)
		RegexJump::jump(@@actions, self, msg, [source])
	end

	# This is a total hack in its current implementation. :)
	def send_raw(source, msg)
		begin
			ircconnection = @client.instance_eval { @ircconnection }
			say(source, explain(ircconnection, msg))
			ircconnection.instance_eval { write(msg) }
		rescue
			say(source, "Could not send in the raw. Is this the SendRaw plugin out-of-date?")
		end
	end

	def explain(ircconnection, msg)
		protocol = ircconnection.secure ? "ircs" : "irc"
		return "#{protocol}://#{ircconnection.host}:#{ircconnection.port} #{msg}"
	end
end

