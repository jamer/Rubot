require 'open-uri'

require 'rubygems'
require 'andand'
require 'nokogiri'

class Weather < RubotPlugin
	@@actions = {
		/^:weather (\d+)$/i => :weather
	}

	def initialize
		super
		@cooldown = IRCCooldown.new(self, 5,
			"Please wait %s more second%s to check the weather.")
	end

	def on_privmsg(user, source, msg)
		RegexJump::jump(@@actions, self, msg, [source])
	end

	def weather(source, area_code)
		return unless @cooldown.trigger_err(source)
		doc = Nokogiri::HTML(open("http://www.wunderground.com/cgi-bin/" +
				"findweather/getForecast?query=#{area_code}"))
		if not valid_zip(doc)
			say(source, "Invalid zip code.")
		else
			relative_temp = doc.xpath("//div[@id='relativeTemp']")
					.andand.at(0)
					.andand.content
			say(source, relative_temp)
		end
	end

	def valid_zip(doc)
		message = doc.xpath("//p[@id='message2']")[0]
		return false if message
		return true
	end
end

