#!/usr/bin/ruby

require "src/sources.rb"

source_dirs = [
	"src/",
	"src/irc",
]


# Load all our source files.
source_dirs.each do |dir| 
	Sources.require_all Dir.glob "#{dir}/*.rb"
end

# Start the program.
Rubot.new.main_loop

