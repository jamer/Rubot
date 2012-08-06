# Rather than code an ugly case statement for a table of functions, we opt for
# a more mathematical model. We describe how different methods relate to simple
# regexps and ask Ruby to link them up for us.
class RegexJump
	def self.try_s2i(arg)
		# If it's a string that looks like an int, cast to an int.
		if arg.class == String and arg =~ /^\d+$/
			return arg.to_i
		else
			return arg
		end
	end

	def self.jump(list, target, str, base_args)
		regex, fn = list.find {|regex, fn| regex.match(str) }
		if regex or fn
			args = (base_args + $~.captures).map! {|arg| try_s2i arg }
			target.send(fn, *args)
			return true
		else
			return false
		end
	end

	def self.get_jump(list, str, base_args)
		regex, fn = list.find {|regex, fn| regex.match(str) }
		if regex or fn
			args = (base_args + $~.captures).map! {|arg| try_s2i arg }
			return fn, args
		else
			return nil
		end
	end
end
