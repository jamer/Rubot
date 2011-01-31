#!/usr/bin/env ruby1.8

require "./src/sources.rb"

source_dirs = [
	"./src/",
	"./src/irc",
]


# Load all our source files.
source_dirs.each do |dir| 
	Sources.require_all Dir.glob "#{dir}/*.rb"
end

# Start the program.
bot = Rubot.new ARGV
bot.main_loop

