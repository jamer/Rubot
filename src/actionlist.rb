
class ActionList
	def initialize(actions, target)
		@actions = actions
		@target = target
	end

	def parse(msg, base_args)
		@actions.each do |regex, fn|
			match = regex.match(msg)
			next if !match

			# A convenience -- update sources if we have a match
			# This enssures we're running the latest version of our code
			Sources.update

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

