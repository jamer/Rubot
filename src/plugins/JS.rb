require 'expect'
require 'pty'

class JS < RubotPlugin
	include Math

	def initialize
		super
		PTY.spawn "js" do |reader, writer, pid|
			@pty_reader = reader
			@pty_writer = writer
		end
	end

	def on_privmsg(user, source, message)
		return unless match = message.match(/^js> (.+)/i)
		expression = match[1]
	#	log "JS #{expression} from #{user.nick}!#{user.name}@#{user.host}"
		command_in_new_thread(source, expression)
	end

	def command_in_new_thread(source, expr)
		thr = Thread.new do
			do_command(expr, source)
		end

		thr.kill if not thr.join(@cmd_timeout)
	end

	def do_command(expr, source)
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
				say(source, line)
			end
		rescue Exception => detail
			return detail.message
		rescue SystemExit
			return "Exitting is disabled."
		end
	end

	def method_missing(symbol, *args)
			@client.send(symbol, *args)
	end
end

