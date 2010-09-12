require 'open-uri'

require 'rubygems'
require 'nokogiri'

class Weather < RubotPlugin
	attr_accessor :cooldown

	def initialize
		@last = 0
		@cooldown = 5
	end

	def privmsg(user, reply_to, message)
		match = message.match /^:weather (\d+)/
		return false unless match
		return false if too_soon reply_to
		area_code = match[1]
		weather reply_to, area_code
		return true
	end

	def too_soon(reply_to)
		time = Time.now
		if time.to_i < @last.to_i + @cooldown
			say reply_to, "I can only check weather every #{@cooldown} seconds." 
			return true
		end
		return false
	end

	def weather(reply_to, area_code)
		@last = Time.now

		doc = Nokogiri::HTML open "http://www.wunderground.com/cgi-bin/" +
				"findweather/getForecast?query=#{area_code}"
		forecasts = doc.xpath "//tr[@class='wHover']/td[@class='full']/div[2]"
		%w(Today Tonight Tomorrow).each_with_index do |time, i|
			say reply_to, "#{time}: #{forecasts[i].content}"
		end
	end
end

