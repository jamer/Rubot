
class ActionList
	def initialize(actions, target)
		@actions = actions
		@target = target
	end

	def parse(msg, base_args)
		@actions.each do |regex, fn|
			match = regex.match(msg)
			next unless match

			yield if block_given?

			args = base_args + match.captures

			# Integer hack, change strings into integers if they match a regexp.
			args.map! do |arg|
				if arg =~ /^\d+$/
					arg = arg.to_i
				end
				arg
			end

			@target.send fn, *args
			return true
		end
		return false
	end
end

