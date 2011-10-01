require 'open-uri'

require 'rubygems'
require 'nokogiri'

class Urban < RubotPlugin
	@@actions = {
		/:urban\s*(.+)/i => :urban,
	}

	def initialize
		super
		@cooldown = IRCCooldown.new(self, 5, "You're searching too fast. Wait %d more second%s.")
	end

	def on_privmsg(user, source, msg)
		RegexJump::jump(@@actions, self, msg, [source])
	end

	def urban(source, word)
		return unless @cooldown.trigger_err(source)
		html = open("http://www.urbandictionary.com/tooltip.php?term=#{word}")
		doc = Nokogiri::HTML(html)
		if doc.content.include?("isn't defined yet")
			say(source, "Not found.")
		else
			definition = doc.xpath("//div[2]")[0].content
			first_line = definition.split(/[\r\n]+/)[1] # [0] is a blank line
			say(source, first_line)
		end
	end
end

