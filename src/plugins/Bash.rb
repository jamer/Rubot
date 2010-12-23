require 'open-uri'

require 'rubygems'
require 'nokogiri'

class Bash < RubotPlugin
	attr_accessor :cooldown

	def initialize
		@cooldown = IRCCooldown.new 5, self,
				"I can only do a bash.org quote every %d seconds."
	end

	def privmsg(user, reply_to, message)
		return false if message != ":bash"
		return false unless @cooldown.irc_ready? reply_to
		bash reply_to
		return true
	end

	def bash(reply_to)
		@cooldown.trigger

		html = open "http://bash.org/?random1"
		doc = Nokogiri::HTML html
		quotes = doc.xpath "//p[@class='qt']"
		quote = quotes[0].content
		quote.split("\n").each { |line| say reply_to, line }
	end
end

