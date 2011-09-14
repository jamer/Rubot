require 'open-uri'

require 'rubygems'
require 'nokogiri'

class Qdb < RubotPlugin
	attr_accessor :cooldown

	def initialize
		super
		@last = 0
		@cooldown = 15
	end

	def on_privmsg(user, source, message)
		return if message != ":qdb"
		return if too_soon(source)
		bash(source)
	end

	def too_soon(source)
		time = Time.now
		if time.to_i < @last.to_i + @cooldown
			say(source, "I can only do a quote every #{@cooldown} seconds." )
			return true
		end
		return false
	end

	def bash(source)
		@last = Time.now

		html = open("http://qdb.us/random")
		doc = Nokogiri::HTML(html)
		quotes = doc.xpath("//span[@class='qt']")
		quote = quotes[0].content
		quote.split("\n").each { |line| say(source, line) }
	end
end

