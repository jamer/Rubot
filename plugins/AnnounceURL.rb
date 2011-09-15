require 'net/http'
require 'open-uri'
require 'uri'

require 'rubygems'
require 'nokogiri'

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

	def initialize
		super
	end

	def on_privmsg(user, source, msg)
		search_for_shortened_urls(source, msg)
	end

	def search_for_shortened_urls(source, msg)
		@@targets.each do |site, url_moves|
			msg.scan(/(#{site}\/[^ ]+)/).map {|i| i[0]}.each do |url|
				output_title(source, "http://#{url}", url_moves)
			end
		end
	end

	def get_moved_url(short_url)
		headers = {
			"Accept" => "text/html;text/plain",
			"Host" => short_url[/^http:\/\/([^\/]+)\//,1],
		}

		url = URI::parse(short_url)
		req = Net::HTTP::Get.new(url.path, headers)
		res = Net::HTTP::start(url.host, url.port) { |http|
			http.request(req)
		}
		return res["Location"]
	end

	def output_title(source, url, url_moves)
		if url_moves
			url = get_moved_url(url)
			return if url.nil?
		end

		if is_image(url)
			handle_image(source, url)
		else
			handle_document(source, url, url_moves)
		end
	end

	def is_image(url)
		["jpg", "jpeg", "png", "gif"].each do |ext|
			return true if url.match(/#{ext}(\?|$)/)
		end
		return false
	end

	def handle_image(source, url)
			say(source, "Image -- http://#{url}")
	end

	def handle_document(source, url, url_moves)
		begin
			doc = Nokogiri::HTML(open(url))
		rescue OpenURI::HTTPError
			return
		end
		titles = doc.css("title")
		titles.each do |title|
			title = title.content.split().join " "
			if url_moves
				say(source, "#{title} -- http://#{url}")
			else
				say(source, "#{title}")
			end
		end
	end
end

