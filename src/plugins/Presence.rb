class Presence < RubotPlugin
	@@actions = {
		/^:show\s+(\S+)$/i => :show,
		/^:list$/i => :list,
		/^:whois\s+(\S+)/i => :scan_whois,
		/^:who$/i => :scan_who,
	}

	def initialize
		super
	end

	def on_privmsg(user, source, line)
		RegexJump::jump(@@actions, self, line, [source])
	end

	def show(source, nick)
		if Users::include?(nick)
			user = Users[nick]
			say(source, user.to_s)
		else
			say(source, "I don't know #{nick}.")
		end
	end

	def list(source)
		puts Users.map {|nick, user| user.to_s }.sort
	end

	def scan_whois(source, target)
		@client.whois(target)
	end

	def scan_who(source)
		@client.who
	end

	def on_whois(user)
		puts "USER #{user}"
	end

	def on_who(user)
		puts "USER #{user}"
	end
end

