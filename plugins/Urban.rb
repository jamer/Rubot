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

	def on_privmsg(user, source, msg)
		return unless match = msg.match(/:urban (.+)/)
		return if too_soon(source)
		word = match[1]
		definition = urban(word)
		say(source, definition)
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
		html = open("http://www.urbandictionary.com/tooltip.php?term=#{word}")
		doc = Nokogiri::HTML(html)
		if doc.content.include?("isn't defined yet")
			return "Not found."
		else
			definition = doc.xpath("//div[2]")[0].content
			first_line = definition.split(/[\r\n]+/)[1] # [0] is a blank line
			return first_line
		end
	end
end

