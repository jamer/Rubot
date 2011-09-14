require 'json'
require 'net/http'
require 'uri'

class Omegle < RubotPlugin
	def initialize
		super
		@t = nil
	end

	def headers sending
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

	def post page, sending, data = ""
		Net::HTTP.new("promenade.omegle.com", 80).start do |http|
			res = http.post "/#{page}", data, headers(sending)
			p res
			return res.body
		end
	end

	def start reply_to
		res = post "start?rcs=1&spid=", false
		@sid = res.gsub '"', ''
#		say reply_to, "Recieved stranger ID: '#{@sid}'"
	end

	def events reply_to
		res = post "events", false, "id=#{@sid}"
#		say reply_to, "Events: #{res}"

		# If this happens, we must have something messed up.
		# Maybe there are new anti-bot measures on Omegle?
		# Check to see if all the POST information is up to date.
		if res == "null"
			say reply_to, "Recieved null event, killing conversation Dx"
			@sid = nil
		end

		# We already disconnected
		if @sid == nil
			return
		end

		events = JSON::parse res
		events.each do |event|
			handle_event reply_to, *event
		end
	end

	def handle_event reply_to, type, msg = ""
		case type
		when "waiting" then
#			say reply_to, "Waiting for stranger"
		when "connected" then
			say reply_to, "has connected", :action
#			say reply_to, "Giving message about being on IRC..."
#			send reply_to, "" +
#				"Hello stranger! Instead of just one stranger, you've been connected " +
#				"to the lobby of the n0v4 IRC network with of tons of strangers! " +
#				"They see everything you say and you see everything they say. Have fun!"
		when "typing" then
#			say reply_to, "is typing", :action
		when "stoppedTyping" then
		when "gotMessage" then
			say reply_to, "#{msg}"
		when "strangerDisconnected" then
			say reply_to, "has disconnected", :action
			@sid = nil
		when "technical reasons" then
			say reply_to, "Omegle has put up a captcha ;_;"
			@sid = nil
		else
			say reply_to, "Unknown event '#{type}'... This is probably bad!"
		end
	end

	def send reply_to, msg
		res = post "send", true, "msg=#{msg}&id=#{@sid}"
		case res
		when "win" then
#			say reply_to, "Sent '#{msg}'"
		when "fail" then
			say reply_to, "Failed to send message '#{msg}'"
		else
			say reply_to, "Unknown send confirmation '#{res}'"
		end
	end

	def disconnect reply_to
		if @t and @t.alive?
			@t.kill
		end
		@sid = nil
		post "disconnect", true
		say reply_to, "You are now disconnected"
	end


	def init_omegle reply_to
		@sid = "no sid yet"
		start reply_to
		@t = Thread.new {
			until @sid == nil do
				events reply_to
			end
		}
	end

	def on_privmsg user, reply_to, message
		if message == ":omegle" or message == ":connect"
			if @t and @t.alive?
				say reply_to, "Stranger already connected"
			else
				init_omegle reply_to
			end
			return true
		elsif @t and @t.alive? and message == ":disconnect"
			disconnect reply_to
			return true
		elsif @t and @t.alive? and message =~ /^-/
			send reply_to, message[1..-1]
			return true
		end

		return false
	end

end

