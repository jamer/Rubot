def log(msg)
	line = "[#{Time.now.strftime("%F %T")}] #{msg}"
	puts line
	open "log.txt", "a" do |f|
		f.puts line
	end
end
