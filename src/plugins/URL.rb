require 'rubygems'
require 'open-uri'
require 'nokogiri'

require 'net/http'
require 'uri'

class URL < RubotPlugin
	@@minifiers = [
		'bit.ly',
		'goo.gl',
		'is.gd',
		'tinyurl.com',
		'tr.im',
		'youtu.be',
		'youtube.com',
		'k.im',
		'bu.tt',
		'sn.im',
		'urls.im',
		'cli.gs',
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

	def get_moved_url short_url
		headers = {
			"Accept" => "text/html;text/plain",
			"Host" => short_url[/^http:\/\/([^\/]+)\//,1],
		}

		url = URI.parse short_url
		req = Net::HTTP::Get.new url.path, headers
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request req
		}
		return res['Location']
	end

	def output_title reply_to, url
		moved = get_moved_url "http://#{url}"
		return if moved.nil?
		if is_image moved
			handle_image reply_to, moved
		else
			handle_document reply_to, moved
		end
	end

	def is_image url
		["jpg", "jpeg", "png", "gif"].each do |ext|
			return true if url.match(/#{ext}$/)
		end
		return false
	end

	def handle_image reply_to, url
			say reply_to, "Image -- http://#{url}"
	end

	def handle_document reply_to, url
		begin
			doc = Nokogiri::HTML open url
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

#
# http://bit.ly/lolkimbo is a JPEG
#
# Perhaps say "JPEG image -- http://bit.ly/lolkimbo"
#

