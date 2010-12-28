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
			say reply_to, do_command(expr)
		end

		thr.kill if not thr.join @cmd_timeout
	end

	def do_command(expr)
		begin
			@pty_writer << expr << "\n"
			
			tosend = ""
			while output =3D @pty_reader.expect(/^>/)
				if output and output.first
					
				end
				tosend += output + "\n"
			end
			return output
			# @pty << expr
			# p @pty.reader
			# return system(expr)
			# return eval(expr)
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

