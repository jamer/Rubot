require 'json'
require 'net/http'
require 'uri'
require 'htmlentities'
require 'time'

# http://search.twitter.com/search.json?lang=en&from={user}

class Tweet < RubotPlugin
	def initialize
		@accounts = {"wikileaks" => 0, "wired" => 0}
		@index = 0
		@needs_to_be_said = []
		
		@coder = HTMLEntities.new
		
		@h = {
			"User-Agent" => "Mozilla/5.0 (Ruby-Twitter; +https://github.com/savetheinternet/Rubot-Twitter)",
			"Accept-Language" => "en-US,en;q=0.8",
			"Referer" => "https://github.com/savetheinternet/Rubot-Twitter"
		}
		
		Thread.new {
			loop {
				do_tweets
				sleep 1
			}
		}
		
		Thread.new {
			loop {
				@needs_to_be_said.each do |line|
					@client.channels.keys.each { |channel| say channel, line }
					@needs_to_be_said.delete line
					sleep 0.3
				end
				sleep 1
			}
		}
	end
	
	def do_tweets
		username = @accounts.keys[@index]
		@accounts[username] = check_new_tweets(username, @accounts[username])
		
		@index+=1
		if @index >= @accounts.count then
			@index = 0
		end
	end
	
	def check_new_tweets(username, since_id)
		Net::HTTP.new("search.twitter.com", 80).start do |http|
			res = http.get "/search.json?lang=en&from=#{username}&since_id=#{since_id}", @h
			
			timeline = JSON.parse res.body
			
			# Show tweets in reverse order. Oldest first.
			tweets = timeline['results'].reverse
			
			# Don't announce first tweets
			if since_id > 0 then
				tweets.each do |tweet|
					on_new_twitter_message @coder.decode(tweet['from_user']), @coder.decode(tweet['text'].split("\n").join " ")
				end
			end
			
			if tweets.empty? then
				return since_id
			else
				return tweets.reverse[0]['id']
			end
			
		end
	end
	
	def privmsg(user, reply_to, message)
		if message =~ /!follow ([A-Za-z0-9]+)/ then
			@accounts[$1] = 0
			say reply_to, "Following \002#{$1}\002."
		end
	end
	
	def on_new_twitter_message(from, message)
		@needs_to_be_said.push "\002[#{from}]\002 #{message}"
	end
end

