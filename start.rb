#!/usr/bin/env ruby

require "./src/sources.rb"

source_dirs = [
	"./src/",
	"./src/irc",
]


# Load all our source files.
source_dirs.each do |dir| 
	Sources.require_all Dir.glob "#{dir}/*.rb"
end

#set_trace_func proc { |event, file, line, id, binding, classname|
#	printf "%8s %s:%-2d %10s %8s\n", event, file, line, id, classname
#}

# Start the program.
bot = Rubot.new ARGV
bot.main_loop

