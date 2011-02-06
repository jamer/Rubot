
require 'json'
require 'open-uri'
require 'uri'

require 'rubygems'
require 'andand'

class Search < RubotPlugin

	def initialize
		@privmsg_actions = {
			/:search\s*(.+)/i => :search,
			/^(w+(h+)?[ao]+t+|w+(h+)?o+|w+[dt]+[fh]+)(\s+(t+h+e+|i+n+|o+n+)\s+(.+?))?((\'+?)?s+|\s+i+s+)\s+(a+(n+)?\s+)?(.+?)(\/|\\|\.|\?|!|$)/i => :search11,
			/^(t+e+l+l+)\s+(m+e+|u+s+|e+v+e+r+y+o+n+e+)\s+(w+(h+)?a+t+|w+h+o+|(a+)?b+o+u+t+)\s+(i+s+|a+(n+)?|)+(.+?)(\s+i+s+|\/|\\|\.|\?|!|$)/i => :search8,
			/^jamer(\S+)?(:|,)?\s+(hi|hello|sup|yo)/i => :say_hi,
			/^(hi|hello|sup|yo)(.+?)?\s+jamer/i => :say_hi,
		}
	end

	def privmsg user, source, message
		if message.match(/#{@client.nick}/i) or message.match(/jamerbot/)
			mkay source
		end
		message.gsub! /#{@client.nick}:?\s+/, ''
		al = ActionList.new @privmsg_actions, self
		return al.parse message, [user.nick, source]
	end

	def search nick, source, message
		fmesg = URI.escape(message.gsub(' ','+'))
		data = open("http://api.duckduckgo.com/?q=#{fmesg}&o=json")
		json = JSON::parse data.readlines.join('\n')
		output = [
				json['AbstractText'],
				json['RelatedTopics'].at(0).andand['Text']
		].delete_if {|x| !x || x.length == 0 }.first
		if output
			say source, output.gsub(/<.*?>/, '')
		else
			say source, "I don't know."
		end
	end

	def search8 nick, source, *unused, message, x
		search nick, source, message
	end

	def search11 nick, source, *unused, message, x
		search nick, source, message
	end

	def say_hi nick, source, *unused
		say source, "Hey #{nick}."
	end

	def mkay source
		if rand % 10 == 0
			say source, "Mkay."
		end
	end

end

