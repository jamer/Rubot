require 'open-uri'

require 'rubygems'
require 'nokogiri'

class Urban < RubotPlugin
	attr_accessor :cooldown

	def initialize
		@last = 0
		@cooldown = 5
	end

	def privmsg(user, reply_to, message)
		return false unless (match = message.match /:urban (.+)/)
		return false if too_soon reply_to
		word = match[1]
		definition = urban word
		say reply_to, definition
		return true
	end

	def too_soon(reply_to)
		time = Time.now
		if time.to_i < @last.to_i + @cooldown
			say reply_to, "I can only do a urban lookup every #{@cooldown} seconds." 
			return true
		end
		return false
	end

	def urban(word)
		@last = Time.now

		html = open "http://www.urbandictionary.com/define.php?term=#{word}"
		doc = Nokogiri::HTML html
		definitions = doc.xpath "//div[@class='definition']"
		definition = definitions[0].content
	end
end

