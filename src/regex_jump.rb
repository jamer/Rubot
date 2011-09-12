
class RegexJump
	def initialize(actions, target)
		@actions = actions
		@target = target
	end

	def try_s2i(arg)
		# If it's a string that looks like an int, cast to an int.
		if arg.class == String and arg =~ /^\d+$/
			return arg.to_i
		else
			return arg
		end
	end

	def parse(msg, base_args)
		regex, fn = @actions.find {|regex, fn| regex.match(msg) }
		if regex or fn then
			yield if block_given?
			captures = regex.match(msg).captures
			args = (base_args + captures).map! {|arg| try_s2i arg }
			@target.send(fn, *args)
			return true
		else
			return false
		end
	end
end

