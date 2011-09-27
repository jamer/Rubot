require 'open-uri'

require 'rubygems'
require 'nokogiri'

class Bash < RubotPlugin
	@@actions = {
		/^:bash$/i => :bash
	}

	def initialize
		super
		@cooldown = IRCCooldown.new(self, 5, "Please wait %s more second%s for a quote.")
	end

	def on_privmsg(user, source, msg)
		RegexJump::jump(@@actions, self, msg, [source])
	end

	def bash(source)
		html = open("http://bash.org/?random1")
		doc = Nokogiri::HTML(html)
		quotes = doc.xpath("//p[@class='qt']")
		quote = quotes[0].content
		quote.split('\n').each { |line| say(source, line) }
	end
end

