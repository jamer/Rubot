class Square
	Piece = %w(empty pawn knight bishop rook queen king)
	Colors = %w(black white)

	attr_accessor :piece, :color

	def initialize piece_char, color
		@piece = get_piece_by_char piece_char
		@color = color
	end

	def get_piece_by_char char
		return {
			'e' => "empty",
			'p' => "pawn",
			'k' => "knight",
			'b' => "bishop",
			'r' => "rook",
			'q' => "queen",
			'k' => "king",
		}[char]
	end

	def get_color_by_word word
		return {
			"black" => '2',
			"white" => '4',
		}[word]
	end

	def char_view
		char = piece[0..0]
		if char == 'e'
			char = ' '
		end
		return "#{get_color_by_word color}#{char}"
	end
end

class Game

	attr_accessor :board

	def initialize
		init_setup = %w(
				rkbkqbkr
				pppppppp
				eeeeeeee
				eeeeeeee
				eeeeeeee
				eeeeeeee
				pppppppp
				rkbqkbkr
		)

		@board = Array.new
		init_setup.each_with_index do |line, row_num|
			@board[row_num] = Array.new
			color = row_num >= 4 ? "white" : "black"
			line.each_char do |c|
				@board[row_num].push Square.new c, color
			end
		end
	end
end

class Chess < RubotPlugin
	def privmsg user, source, message
		al = ActionList.new @@privmsg_actions, self
		return al.parse message, [user, source]
	end

	@@privmsg_actions = {
		/^:display$/i => :display,
	}

	def game
		@game |= Game.new
		return @game
	end

	def display user, source
		game.board.each do |row|
			row.map! {|sq| sq.char_view}
			say source, row.join
		end
	end
end

