#!/usr/bin/ruby

require "sources.rb"

source_dirs = [
	".",
	"irc",
]

this_file = __FILE__
Sources.ignore this_file

source_dirs.each do |dir| 
	files = Dir.glob "#{dir}/*.rb"
	Sources.load_all files
end

Roobot.init
Roobot.main_loop

