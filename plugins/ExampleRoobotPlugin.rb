
class ExampleRoobotPlugin < RoobotPlugin
	# This is only an example plugin. Remove the following line or set
	# to false to activate this plugin.
	@innert = true

	# You can either create a new bot specifically for the plugin, or you
	# can hook into an already existing one.
	@bot = :main
	@bot = {
		id => :plugin_demo

		# If any fields (server, port, ...) are missing, fill them in with
		# values from another bot. This allows you to easily create a bot
		# on the same network as your main bot -- just with a different 
		# nickname.
		base => :main

		server => "irc.omegadev.org"
		port => 6667

		nick = "RoobotPluginDemo"
		realname = "JustAPlugin"

		# Channels can either be a String or an Array. Your choice.
		channel => "#lobby"
		channels => {
			"#lobby",
			"#lib",
		}
	}

	# Listen in to lines coming from the IRC server.
	#
	# Return true if you handled the line yourself. Returning false will
	# give other plugins a chance to handle the line.
	def listener(line)
		return false
	end

	# We have a dedicated PRIVMSG listener function for convenience.
	def privmsg_listener(nick, realname, host, source, message)
		return false
	end
end

