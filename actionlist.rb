
class ActionList
	def initialize(actions, target)
		@actions = actions
		@target = target
	end

	def parse(msg, base_args)
		@actions.each do |fn, regex|
			match = regex.match(msg)
			next if !match

			# Yield if we have a match.
			yield

			args = base_args + match.captures

			# Integer hack, change strings into integers if they match a regexp.
			args.map! do |arg|
				if arg =~ /^\d+$/
					arg = arg.to_i
				end
				arg
			end

			# Send the function only the number of args that it needs.
			arg_count = @target.method(fn).arity
			@target.send fn, *args.slice(0, arg_count)
			return true
		end
		return false
	end
end

