module Kernel
	def `(cmd)
		return "System calls are disabled."
	end

	def system(cmd)
		return "System calls are disabled."
	end

	def exec(cmd)
		return "System calls are disabled."
	end
end
