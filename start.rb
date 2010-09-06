#!/usr/bin/ruby

require "sources.rb"

source_dirs = [
	".",
	"irc",
]


# Load all our source files.
this_file = "./" + __FILE__
Sources.ignore this_file

source_dirs.each do |dir| 
	Sources.require_all Dir.glob "#{dir}/*.rb"
end

# Start the program.
Roobot.init
Roobot.main_loop

