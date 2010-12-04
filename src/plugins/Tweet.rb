require 'json'
require 'net/http'
require 'uri'
require 'htmlentities'

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
				sleep 5
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
	
	def announce_tweets(tweets, channel=nil)
		tweets.each do |tweet|
			from = @coder.decode(tweet['from_user'])
			message = @coder.decode(tweet['text'].split("\n").join " ")
			
			if channel.nil? then
				@needs_to_be_said.push "\002[#{from}]\002 #{message}"
			else
				say channel, "\002[#{from}]\002 #{message}"
			end
		end
	end
	
	def search_tweets(channel, query, type)
		uri = "/search.json?lang=en&q=#{query}&rpp=5&result_type=#{type}"
		
		Net::HTTP.new("search.twitter.com", 80).start do |http|
			res = http.get uri, @h
			timeline = JSON.parse res.body
			if not timeline.include? 'results' then
				return "\002Error\002: [#{uri}] #{timeline.to_s}"
			end
			
			if timeline['results'].empty? then
				return "No results."
			end
			announce_tweets timeline['results'].reverse, channel
		end
		nil
	end
	
	def format_number(n)
		return n.to_s.reverse.gsub(/...(?=.)/, '\&,').reverse
	end
	
	def do_info(channel, username)
		uri = "/1/users/show/#{username}.json"
		Net::HTTP.new("api.twitter.com", 80).start do |http|
			res = http.get uri, @h
			info = JSON.parse res.body
			
			@info = [
				["Screen name", "screen_name"],
				["Name", "name"],
				["Location", "location"],
				["Description", "description"],
				["URL", "url"],
				["Created", "created_at"],
				["Followers", "followers_count"]
			]
			
			if info.include? "error" then
				say channel, "\002Error\002: #{info["error"]}"
				return
			end
			
			@info.each do |x|
				name = x[0]
				key = x[1]
				
				if info.include? key then
					if info[key].class == Fixnum then
						info[key] = format_number info[key]
					end
					if !info[key].nil? && !info[key].empty? then
						say channel, "\002#{name}\002: #{info[key].split("\n").join " "}"
					end
				end
			end
		end
	end
	
	def do_latest(channel, username, count)
		uri = "/search.json?lang=en&from=#{username}&rpp=#{count}"
		Net::HTTP.new("search.twitter.com", 80).start do |http|
			res = http.get uri, @h
			
			timeline = JSON.parse res.body
			
			# Show tweets in reverse order. Oldest first.
			if not timeline.include? 'results' then
				@needs_to_be_said.push "\002Error\002: [#{uri}] #{timeline.to_s}"
				return since_id
			end
			
			if timeline['results'].empty? then
				return "No tweets."
			end
			tweets = timeline['results'].reverse
			
			announce_tweets tweets, channel
		end
	end
	
	def check_new_tweets(username, since_id)
		uri = "/search.json?lang=en&from=#{username}&since_id=#{since_id}"
		
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
		if message =~ /^!follow ([A-Za-z0-9_]+)$/ then
			username = $1.to_sym
			if @accounts.include? username then
				say reply_to, "I'm already following \002#{$1}\002."
			else
				@accounts[username] = 0
				say reply_to, "Following \002#{$1}\002."
			end
		elsif message =~ /^!unfollow ([A-Za-z0-9_]+)$/ then
			username = $1.to_sym
			if @accounts.include? username then
				@accounts.delete username
				say reply_to, "Stopped following \002#{$1}\002."
			else
				say reply_to, "I'm not following \002#{$1}\002!"
			end
		elsif message =~ /^!following$/ then
			say reply_to, "Following: \002#{@accounts.keys.join ", "}\002."
		elsif message =~ /^!debug$/ then
			@accounts.each do |account, id|
				say reply_to, "\002#{account}\002: #{id}."
			end
		elsif message =~ /^!info ([A-Za-z0-9_]+)$/ then
			do_info reply_to, $1
		elsif message =~ /^!latest ([A-Za-z0-9_]+)$/ then
			do_latest reply_to, $1, 1
		elsif message =~ /^!latest (\d+) ([A-Za-z0-9_]+)$/ then
			do_latest reply_to, $2, $1
		elsif message =~ /^!search (.+)$/ then
			say reply_to, search_tweets(reply_to, (URI.escape $1), "recent")
		elsif message =~ /^!popular (.+)$/ then
			say reply_to, search_tweets(reply_to, (URI.escape $1), "popular")
		end
	end
end

