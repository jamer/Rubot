def show_stack_trace
	begin
		raise "Stack trace"
	rescue Exception => e
		puts e.backtrace
	end
end

