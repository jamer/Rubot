require 'open-uri'

require 'rubygems'
require 'nokogiri'

class Weather < RubotPlugin
	attr_accessor :cooldown

	def initialize
		@cooldown = IRCCooldown.new 5, self,
				"I can only check the weather every %d seconds."
	end

	def privmsg(user, reply_to, message)
		return false unless (match = message.match /^:weather (\d+)/)
		return false unless @cooldown.irc_ready? reply_to
		area_code = match[1]
		weather reply_to, area_code
		return true
	end

	def weather(reply_to, area_code)
		@cooldown.trigger

		doc = Nokogiri::HTML open "http://www.wunderground.com/cgi-bin/" +
				"findweather/getForecast?query=#{area_code}"
		forecasts = doc.xpath "//tr[@class='wHover']/td[@class='full']/div[2]"
		%w(Today Tonight Tomorrow).each_with_index do |time, i|
			say reply_to, "#{time}: #{forecasts[i].content}"
		end
	end
end

