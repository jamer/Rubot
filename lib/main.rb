#!/usr/bin/env ruby

# Add directory above this file to 'require' search path.
$:.push File::expand_path("../..", __FILE__)

# Load all of our source files.
require 'find'
Find::find("lib") do |path|
	if File::file?(path) and path.end_with?(".rb")
		if not path.end_with?(__FILE__)
			require path
		end
	end
end

#set_trace_func proc { |event, file, line, id, binding, classname|
#	printf "%8s %s:%-2d %10s %8s\n", event, file, line, id, classname
#}

# Start the program.
require 'lib/rubot/rubot.rb'
bot = Rubot::new(ARGV)
bot.main_loop
