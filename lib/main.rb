#!/usr/bin/env ruby
$:.push File.expand_path("../..", __FILE__)

source_dirs = [
	"lib",
	"lib/ext",
	"lib/rubot",
]

# Load all our source files.
source_dirs.each do |dir| 
	files = Dir.glob("#{dir}/*.rb")
	files = files.reject {|f| f == __FILE__ }
	files.each do |file|
		require file
	end
end

#set_trace_func proc { |event, file, line, id, binding, classname|
#	printf "%8s %s:%-2d %10s %8s\n", event, file, line, id, classname
#}

# Start the program.
bot = Rubot.new(ARGV)
bot.main_loop

