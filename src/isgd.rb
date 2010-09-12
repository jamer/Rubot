require 'open-uri'
require 'rubygems'
require 'nokogiri'

def isgd(url)
	encode = URI::escape url, "?&:/="
	response = Nokogiri::HTML open "http://is.gd/api.php?longurl=#{encode}"
	shortened = response.content
	return shortened
end

