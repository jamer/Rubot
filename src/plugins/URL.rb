require 'rubygems'
require 'open-uri'
require 'nokogiri'

class URL < RubotPlugin
	@@minifiers = [
		'bit.ly',
		'goo.gl',
		'is.gd',
		'tinyurl.com',
		'tr.im',
		'youtu.be',
		'youtube.com',
	]

	def privmsg user, reply_to, message
		search_for_shortened_urls reply_to, message
	end

	def search_for_shortened_urls reply_to, message
		@@minifiers.each do |site|
			message.scan(/(#{site}\/[^ ]+)/).map {|i| i[0]}.each do |url|
				output_title reply_to, url
			end
		end
	end

	def output_title reply_to, url
		begin
			doc = Nokogiri::HTML open "http://#{url}"
		rescue OpenURI::HTTPError
			return
		end
		titles = doc.css('title')
		titles.each do |title|
			title = title.content.split().join " "
			say reply_to, "#{title} -- http://#{url}"
		end
	end
end

