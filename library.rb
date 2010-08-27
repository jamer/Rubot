
class Book
	attr_accessor :name

	def initialize(name)
		@name = name + ".book"
		@exists = File.exists? @name
		validate_path
		puts "Name is #{@name}"
	end

	def validate_path
		# Protect against dangerous paths
		if @name.include? "/" or @name.include? "\\"
			@exists = false
		end
	end

	def exists?
		return @exists
	end

	def read(offset, count)
		return if !exists?
		file = File.new @name
		offset.times { file.gets }
		lines = []
		count.times { lines << file.gets.strip + " " }
		file.close
		return lines
	end

end



class Library
	class << self

		@@books ||= {}

		def get_book(name)
			name.downcase!
			if not @@books.include? name
				book = Book.new name
				@@books[name] = book if book.exists?
			end
			return @@books[name]
		end

		def list_books
			return Dir.glob("*.book").collect do |name|
				name = name.gsub(".book", "")
				name.capitalize_each_word!
			end
		end

	end
end



class User
	attr_accessor :line
	attr_accessor :chunk

	def initialize(name)
		@nick = name
		@chunk = 10
	end

	def nick
		return @nick
	end

	def book
		return @book
	end

	def book=(book)
		@book = book
		@line = -@chunk
	end

	def read
		@line += @chunk
		return book.read @line, @chunk
	end

	def resume
		return book.read @line, @chunk
	end
end


class UserBase
	class << self
		attr_accessor :users

		@@users ||= {}

		def ensure_registered(name)
			if !@@users.include? name
				@@users[name] = User.new(name)
			end
		end

		def get_user(name)
			@@users ||= {}
			ensure_registered(name)
			return @@users[name]
		end

	end
end

