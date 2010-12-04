require 'json'
require 'net/http'
require 'uri'
require 'htmlentities'

# http://search.twitter.com/search.json?lang=en&from={user}

class Tweet < RubotPlugin

		
	def check_new_tweets(username)
		Net::HTTP.new("search.twitter.com", 80).start do |http|
			res = http.get "/search.json?lang=en&from=#{username}"
			p res
			
			timeline = JSON.parse res.body
			timeline['results'].each do |tweet|
				on_new_twitter_message @coder.decode(tweet['from_user']), @coder.decode(tweet['text'])
			end
			
			return res.body
		end
	end
	
	def initialize
		@coder = HTMLEntities.new
	end

	def privmsg(user, reply_to, message)
		check_new_tweets("wikileaks")
		say reply_to, "I heard you, #{user.nick}"
	end
	
	def on_new_twitter_message(from, message)
		@client.channels.keys.each { |channel| say channel, "#{from} says #{message}" }
	end
end

