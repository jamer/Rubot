# Replace \/ with /

require 'lib/icase-hash.rb'

class Typo < RubotPlugin

	# Attention: Matches that look like numbers will be converted to numbers, and
	# will no longer be strings.
	@@actions = [
		#  s /old              /new                     /gi
		[/^s\/(([^\/]|\\\/)+?)\/(([^\/]|\\\/)+?(\\\/)?)\/?([gi]*)$/, :correct_self],
		#  nick        /old              /new                     /gi
		[/^([^\s\/]+?)\/(([^\/]|\\\/)+?)\/(([^\/]|\\\/)+?(\\\/)?)\/?([gi]*)$/, :correct_other],
# broken
#		[/^([^:,]+)[:,\s].*?s\/(.+)\/(.+?)\/?$/, :correct_other], # nick: s/old/new/
		[/(.+)/, :remember_line],
	]

	def initialize
		super

		# Remember this many previous lines for each user.
		@remembered = 10

		# This will hold previous messages from all users we see.
		@msgs = IgnoreCaseHash.new
	end

	def on_privmsg(user, source, msg)
		RegexJump::jump(@@actions, self, msg, [user, source])
	end

	# A user said something, let's write it down.
	def add_history_item(nick, msg)
		@msgs[nick] = Array.new unless @msgs[nick]
		@msgs[nick].unshift(msg)
		@msgs[nick].pop if @msgs[nick].length > @remembered
	end

	def replace(source, nick, orig, cor, flags)
		orig = orig.to_s
		cor = cor.to_s

		return unless @msgs[nick]
		found = @msgs[nick].find {|msg| msg =~ /#{orig}/ }
		return unless found
		if flags.include?("i")
			regex = /#{orig}/i
		else
			regex = /#{orig}/
		end
		if flags.include?("g")
			corrected = found.gsub(regex, cor)
		else
			corrected = found.sub(regex, cor)
		end
		say(source, "#{nick} meant to say: #{corrected}")
		add_history_item(nick, corrected)
	end

	# I don't know why _3 is needed. Is it a bug that is present in 1.8? Does 1.9 or 2.0 need it?
	def correct_self(user, source, orig, _1, cor, _2, _3, flags)
		nick = user.nick
		replace(source, nick, orig, cor, flags)
	end

	# I don't know why _3 is needed. Is it a bug that is present in 1.8? Does 1.9 or 2.0 need it?
	def correct_other(user, source, nick, orig, _1, cor, _2, _3, flags)
		replace(source, nick, orig, cor, flags)
	end

	def remember_line(user, source, msg)
		msg = msg.to_s

		nick = user.nick
		if msg =~ /^\001/
			msg.sub!(/^\001ACTION/, "* #{user.nick}")
			msg.sub!(/\001$/, "")
		end
		add_history_item(nick, msg)
	end
end

