require 'open-uri'

require 'rubygems'
require 'nokogiri'

class Qdb < RubotPlugin
	attr_accessor :cooldown

	def initialize
		@cooldown = IRCCooldown.new 15, self,
				"I can only do a qdb.us quote every %d seconds."
	end

	def privmsg(user, reply_to, message)
		return false if message != ":qdb"
		return false unless @cooldown.irc_ready? reply_to
		bash reply_to
		return true
	end

	def bash(reply_to)
		@cooldown.trigger

		html = open "http://qdb.us/random"
		doc = Nokogiri::HTML html
		quotes = doc.xpath "//span[@class='qt']"
		quote = quotes[0].content
		quote.split("\n").each { |line| say reply_to, line }
	end
end

