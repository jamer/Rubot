class Thread
	def new_print_exceptions(&block)
		Thread.new do
			begin
				block.call
			rescue SystemExit
				# Don't stop program exits.
			rescue Exception => detail
				puts "Exception caught - #{detail.class}(\"#{detail.message}\")"
				puts detail.backtrace.join("\n")
				puts
			end
		end
	end
end
