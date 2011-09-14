require 'open-uri'

require 'rubygems'
require 'nokogiri'

class Urban < RubotPlugin
	attr_accessor :cooldown

	def initialize
		super
		@last = 0
		@cooldown = 5
	end

	def on_privmsg(user, source, line)
		return false unless (match = line.match /:urban (.+)/)
		return false if too_soon(source)
		word = match[1]
		definition = urban(word)
		say(source, definition)
		return true
	end

	def too_soon(source)
		time = Time.now
		if time.to_i < @last.to_i + @cooldown
			say(source, "I can only do an urban lookup every #{@cooldown} seconds.")
			return true
		else
			return false
		end
	end

	def urban(word)
		@last = Time.now
		html = open("http://www.urbandictionary.com/define.php?term=#{word}")
		doc = Nokogiri::HTML(html)
		definitions = doc.xpath("//div[@class='definition']")
		definition = definitions[0].content
	end
end

