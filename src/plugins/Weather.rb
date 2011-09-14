require 'open-uri'

require 'rubygems'
require 'nokogiri'

class Weather < RubotPlugin
	attr_accessor :cooldown

	def initialize
		super
		@last = 0
		@cooldown = 5
	end

	def on_privmsg(user, source, message)
		return unless match = message.match(/^:weather (\d+)/)
		return if too_soon(source)
		area_code = match[1]
		weather(source, area_code)
	end

	def too_soon(source)
		time = Time.now
		if time.to_i < @last.to_i + @cooldown
			say(source, "I can only check weather every #{@cooldown} seconds." )
			return true
		end
		return false
	end

	def weather(source, area_code)
		@last = Time.now

		doc = Nokogiri::HTML(open("http://www.wunderground.com/cgi-bin/" +
				"findweather/getForecast?query=#{area_code}"))
		forecasts = doc.xpath("//tr[@class='wHover']/td[@class='full']/div[2]")
		%w(Today Tonight Tomorrow).each_with_index do |time, i|
			say(source, "#{time}: #{forecasts[i].content}")
		end
	end
end

