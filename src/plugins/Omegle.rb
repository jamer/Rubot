require 'json'
require 'net/http'
require 'uri'

class Omegle < RubotPlugin
	def initialize
		super
		@t = nil
	end

	def headers(sending)
		h = {
			"User-Agent" => "Mozilla/5.0 (X11; U; Linux x86_64; en-US) AppleWebKit/534.10 (KHTML, like Gecko) Chrome/8.0.552.28 Safari/534.10",
			"Accept-Charset" => "ISO-8859-1,utf-8;q=0.7,*;q=0.3",
			"Accept-Encoding" => "gzip,deflate",
			"Accept-Language" => "en-US,en;q=0.8",
			"Connection" => "keep-alive",
			"Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8",
			"Keep-Alive" => "300",
			"Host" => "http://promenade.omegle.com",
			"Origin" => "http://promenade.omegle.com",
			"Referer" => "http://promenade.omegle.com/",
		}
		if sending
			h["Accept"] = "text/javascript, text/html, application/xml, text/xml, */*"
		else
			h["Accept"] = "text/json"
		end
		return h
	end

	def post(page, sending, data = "")
		Net::HTTP.new("promenade.omegle.com", 80).start do |http|
			res = http.post("/#{page}", data, headers(sending))
			return res.body
		end
	end

	def start(source)
		res = post("start?rcs=1&spid=", false)
		@sid = res.gsub('"', '')
#		say(source, "Recieved stranger ID: '#{@sid}'")
	end

	def events(source)
		res = post("events", false, "id=#{@sid}")
#		say(source, "Events: #{res}")

		# If this happens, we must have something messed up.
		# Maybe there are new anti-bot measures on Omegle?
		# Check to see if all the POST information is up to date.
		if res == "null"
			say(source, "Recieved null event, killing conversation. Dx")
			@sid = nil
		end

		# We already disconnected
		if @sid.nil?
			return
		end

		events = JSON::parse(res)
		events.each do |event|
			handle_event(source, *event)
		end
	end

	def handle_event(source, type, msg = "")
		case type
		when "waiting" then
#			say(source, "Waiting for stranger")
		when "connected" then
			say(source, "has connected", :action)
#			say(source, "Giving message about being on IRC...")
#			send(source, "" +
#				"Hello stranger! Instead of just one stranger, you've been connected " +
#				"to the lobby of the n0v4 IRC network with of tons of strangers! " +
#				"They see everything you say and you see everything they say. Have fun!")
		when "typing" then
#			say(source, "is typing", :action)
		when "stoppedTyping" then
		when "gotMessage" then
			say(source, "#{msg}")
		when "strangerDisconnected" then
			say(source, "has disconnected", :action)
			@sid = nil
		when "technical reasons" then
			say(source, "Omegle has put up a captcha ;_;")
			@sid = nil
		else
			say(source, "Unknown event '#{type}'... This is probably bad!")
		end
	end

	def send(source, msg)
		res = post("send", true, "msg=#{msg}&id=#{@sid}")
		case res
		when "win" then
#			say(source, "Sent '#{msg}'")
		when "fail" then
			say(source, "Failed to send message '#{msg}'")
		else
			say(source, "Unknown send confirmation '#{res}'")
		end
	end

	def disconnect(source)
		if @t and @t.alive?
			@t.kill
		end
		@sid = nil
		post("disconnect", true)
		say(source, "You are now disconnected")
	end


	def init_omegle(source)
		@sid = "no sid yet"
		start(source)
		@t = Thread.new {
			until @sid == nil do
				events(source)
			end
		}
	end

	def on_privmsg(user, source, msg)
		if msg == ":omegle" or msg == ":connect"
			if @t and @t.alive?
				say(source, "Stranger already connected")
			else
				init_omegle(source)
			end
		elsif @t and @t.alive? and msg == ":disconnect"
			disconnect(source)
		elsif @t and @t.alive? and msg =~ /^-/
			send(source, msg[1..-1])
		end
	end
end

