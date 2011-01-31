require 'rubygems'
require 'open-uri'
require 'nokogiri'

require 'net/http'
require 'uri'

class AnnounceURL < RubotPlugin
	@@targets = [
		# [Domain, URL relocation service]
		['bit.ly', true],
		['goo.gl', true],
		['is.gd', true],
		['tinyurl.com', true],
		['tr.im', true],
		['k.im', true],
		['bu.tt', true],
		['sn.im', true],
		['urls.im', true],
		['cli.gs', true],
		['youtu.be', true],

		['youtube.com', false],
	]

	def privmsg user, reply_to, message
		search_for_shortened_urls reply_to, message
	end

	def search_for_shortened_urls reply_to, message
		@@targets.each do |site, url_moves|
			message.scan(/(#{site}\/[^ ]+)/).map {|i| i[0]}.each do |url|
				output_title reply_to, "http://#{url}", url_moves
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
		res = Net::HTTP.start(url.host, url.port) { |http|
			http.request req
		}
		return res['Location']
	end

	def output_title reply_to, url, url_moves
		if url_moves
			url = get_moved_url url
			return if url.nil?
		end

		if is_image url
			handle_image reply_to, url
		else
			handle_document reply_to, url, url_moves
		end
	end

	def is_image url
		["jpg", "jpeg", "png", "gif"].each do |ext|
			return true if url.match(/#{ext}(\?|$)/)
		end
		return false
	end

	def handle_image reply_to, url
			say reply_to, "Image -- http://#{url}"
	end

	def handle_document reply_to, url, url_moves
		begin
			doc = Nokogiri::HTML open url
		rescue OpenURI::HTTPError
			return
		end
		titles = doc.css('title')
		titles.each do |title|
			title = title.content.split().join " "
			if url_moves
				say reply_to, "#{title} -- http://#{url}"
			else
				say reply_to, "#{title}"
			end
		end
	end
end

