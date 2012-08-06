module Enumerable
	def map_first(&block)
		each do |el|
			x = yield(el)
			return x if x
		end
		return nil
	end
end
