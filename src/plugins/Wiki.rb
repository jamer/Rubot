require 'open-uri'

require 'rubygems'
require 'nokogiri'

class Wiki < RubotPlugin
	def initialize
		@cool = IRCCooldown.new 5, self,
				"I can only do a wiki lookup every %d seconds."
		@memory = Hash.new
	end

	def privmsg(user, reply_to, message)
		return unless (match = message.match /:wiki (.+)/i)
		topic = match[1]
		say reply_to, lookup(topic)
	end

	def lookup(topic)
		return @memory[topic] if @memory.include? topic
		summary = format download topic
		@memory[topic] = summary
	end

	def download(topic)
		doc = Nokogiri::HTML open "http://en.wikipedia.org/wiki/#{topic}"
		tocs = doc.xpath("//table[@id='toc']")
		intro = rm_nbsp doc.xpath("//p")[0].content
	end

	def rm_nbsp(text)
		text.gsub [160].pack("U"), " "
	end

	def format(intro)
		summary rm_refs rm_stocks intro
	end

	def summary(text)
		chopped = text[0..400]
		summary = chopped.include?(".") ? chopped[/.*\./] : chopped
	end

	def rm_refs(text)
		text.gsub /\[\d+\]/, ""
	end

	def rm_stocks(text)
		text.gsub /\ \(([A-Z]+: [A-Z0-9]{4,5}(, )?)+\)/, ""
	end
end

