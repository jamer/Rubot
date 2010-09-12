require 'open-uri'

require 'rubygems'
require 'nokogiri'

class Bash < RubotPlugin
	attr_accessor :cooldown

	def initialize
		@last = 0
		@cooldown = 5
	end

	def privmsg(user, reply_to, message)
		return false if message != ":bash"
		return false if too_soon reply_to
		bash reply_to
		return true
	end

	def too_soon(reply_to)
		time = Time.now
		if time.to_i < @last.to_i + @cooldown
			say reply_to, "I can only do a quote every #{@cooldown} seconds." 
			return true
		end
		return false
	end

	def bash(reply_to)
		@last = Time.now

		html = open "http://bash.org/?random1"
		doc = Nokogiri::HTML html
		quotes = doc.xpath "//p[@class='qt']"
		quote = quotes[0].content
		quote.split("\n").each { |line| say reply_to, line }
	end
end

