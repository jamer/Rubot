require 'json'
require 'net/http'
require 'uri'
require 'htmlentities'
require 'time'

# http://search.twitter.com/search.json?lang=en&from={user}

class Tweet < RubotPlugin
	def initialize
		@accounts = {:wikileaks => 0, :wired => 0}
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
		@accounts[username] = check_new_tweets(username.to_s, @accounts[username])
		
		@index+=1
		if @index >= @accounts.count then
			@index = 0
		end
	end
	
	def announce_tweets(tweets)
		tweets.each do |tweet|
			on_new_twitter_message @coder.decode(tweet['from_user']), @coder.decode(tweet['text'].split("\n").join " ")
		end
	end
	
	def search_tweets(query)
		uri = "/search.json?lang=en&q=#{query}&rpp=5"
		
		Net::HTTP.new("search.twitter.com", 80).start do |http|
			res = http.get uri, @h
			timeline = JSON.parse res.body
			if not timeline.include? 'results' then
				return "\002Error\002: [#{uri}] #{timeline.to_s}"
			end
			
			if timeline['results'].empty? then
				return "No results."
			end
			announce_tweets timeline['results'].reverse
		end
		nil
	end
	
	def check_new_tweets(username, since_id)
		if since_id < 0 then
			# Latest
			uri = "/search.json?lang=en&from=#{username}&rpp=1"
		else
			# Tweets after given ID
			uri = "/search.json?lang=en&from=#{username}&since_id=#{since_id}"
		end
		
		Net::HTTP.new("search.twitter.com", 80).start do |http|
			res = http.get uri, @h
			
			timeline = JSON.parse res.body
			
			# Show tweets in reverse order. Oldest first.
			if not timeline.include? 'results' then
				@needs_to_be_said.push "\002Error\002: [#{uri}] #{timeline.to_s}"
				return since_id
			end
			tweets = timeline['results'].reverse
			
			# Don't announce first tweets
			if since_id != 0 then
				announce_tweets tweets
			end
			
			if tweets.empty? then
				return since_id
			else
				return tweets.reverse[0]['id']
			end
			
		end
	end
	
	def privmsg(user, reply_to, message)
		if message =~ /^!follow ([A-Za-z0-9]+)$/ then
			username = $1.to_sym
			if @accounts.include? username then
				say reply_to, "I'm already following \002#{$1}\002."
			else
				@accounts[username] = 0
				say reply_to, "Following \002#{$1}\002."
			end
		elsif message =~ /^!unfollow ([A-Za-z0-9]+)$/ then
			username = $1.to_sym
			if @accounts.include? username then
				@accounts.delete username
				say reply_to, "Stopped following \002#{$1}\002."
			else
				say reply_to, "I'm not following \002#{$1}\002!"
			end
		elsif message =~ /^!following$/ then
			say reply_to, "Following: \002#{@accounts.keys.join ", "}\002."
		elsif message =~ /^!latest ([A-Za-z0-9]+)$/ then
			check_new_tweets $1, -1
		elsif message =~ /^!search (.+)$/ then
			say reply_to, search_tweets(URI.escape $1)
		end
	end
	
	def on_new_twitter_message(from, message)
		@needs_to_be_said.push "\002[#{from}]\002 #{message}"
	end
end

