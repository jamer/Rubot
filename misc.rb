
def log(msg)
	puts "[#{Time.new.strftime("%a %H:%M:%S")}] #{msg}"
end

def resource
	log "Resourcing"
	load SOURCE
end

def run_only_once(desc)
	@@symbols ||= {}
	if not @@symbols[desc]
		@@symbols[desc] = true
		yield
	end
end





class String
	def capitalize_each_word!
		capitalize!
		for i in (1...length)
			self[i] -= 32 if self[i-1] == 32
		end
		return self
	end

	def proper_grammar!
		capitalize!
		strip!
		if self[length-1] != '.'[0]
			return self + "."
		end
		return self
	end
end

class Array
	def random
		return self[rand length]
	end
end




def Kernel::system(*args)
	return "Nice try."
end

def system(*args)
	return "Nice try."
end

def Kernel::exec(*args)
	return "Nice try."
end

def exec(*args)
	return "Nice try."
end

def Process::exit!(*args)
	return "Nice try."
end

def exit!(*args)
	return "Nice try."
end


