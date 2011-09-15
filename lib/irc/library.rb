
class Book
	attr_accessor :name

	def initialize(name)
		@name = name + ".book"
		@exists = File.exists? @name
		validate_path
	end

	def validate_path
		# Protect against dangerous paths
    ["/", "\\"].each do |c|
      @exists = false if @name.include? c
    end
	end

	def exists?
		return @exists
	end

	def read(offset, count)
		return if !exists?
    lines = []
		File.open @name do |file|
			offset.times { file.gets }
			count.times { lines << file.gets.strip + " " }
		end
		return lines
	end

end



class Library
	class << self

		@@books ||= {}


		def load_book(title)
			if !@@books.include? title
				book = Book.new title
				@@books[title] = book
			end
		end

		def get_book(title)
			title.downcase!
			load_book title
			return @@books[title]
		end

		def [](title)
			return get_book title
		end

		def list_books
			return Dir.glob("*.book").collect do |name|
				name = name.gsub(".book", "")
				name.capitalize_each_word!
			end.sort
		end

	end
end



class LibUser
	attr_accessor :line
	attr_accessor :chunk

	def initialize(name)
		@nick = name
		@chunk = 20
	end

	def nick
		return @nick
	end

	def book
		return @book
	end

	def book=(book)
		@book = book
		@line = 0
	end

	def read
		lines = resume
		@line += @chunk
		return lines
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
				@@users[name] = LibUser.new name
			end
		end

		def get_user(name)
			@@users ||= {}
			ensure_registered name
			return @@users[name]
		end

		def [](name)
			return get_user name.to_sym
		end

	end
end

