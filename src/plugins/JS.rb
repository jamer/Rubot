require 'pty'
require 'expect'

class JS < RubotPlugin
	include Math

	def initialize
		PTY.spawn "js" do |reader, writer, pid|
			@pty_reader = reader
			@pty_writer = writer
		end
	end

	def privmsg(user, reply_to, message)
		match = message.match(/^js> (.+)/i)
		return false if !match
		expression = match[1]
		Sources.update
	#	log "JS #{expression} from #{user.nick}!#{user.name}@#{user.host}"
		command_in_new_thread reply_to, expression
	end

	def command_in_new_thread(reply_to, expr)
		thr = Thread.new do
			do_command(expr, reply_to)
		end

		thr.kill if not thr.join @cmd_timeout
	end

	def do_command(expr, reply_to)
		begin
			output = ""

			@pty_writer << expr << "\n"
			while c = @pty_reader.getc do
				output += c
				if output =~ /\njs> $/ then
					break
				end
			end
			
			lines = output.split("\n")
			lines.slice(1, lines.count-2).each do |line|
				say reply_to, line
			end
		rescue Exception => detail
			return detail.message
		rescue SystemExit
			return "Exitting is disabled."
		end
	end

	def method_missing(symbol, *args)
			@client.send symbol, *args
	end

end

