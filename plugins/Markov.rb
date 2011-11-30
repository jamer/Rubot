# Random sentence generator built using Markov chains

require 'sqlite3'

class MemMC
	attr_reader :order

	def initialize(order)
		@order = order
		clear
	end

	def add_beginning(state)
		@beg << state
	end

	def add_follow(lead, follow)
		@freq[lead] ||= []
		@freq[lead] << follow
	end

	def single_transaction(&block)
		block.call
	end

	def get_beginning
		len = @beg.size
		return [ @beg[rand(len)] ]
	end

	def get_follow(state)
		possible = @freq[state]
		return nil if possible.nil?
		len = possible.size
		return [ possible[rand(len)] ]
	end

	def clear
		@beg = []
		@freq = {}
	end
end

class SqliteMC
	DB_FILE = "dbs/markov.db"

	attr_reader :order

	def initialize(order)
		@order = order

		@db = SQLite3::Database.new(DB_FILE)
		init_db if db_empty?
		@add_freq_prep = @db.prepare("INSERT INTO freq VALUES(?, ?)")
		@add_beg_prep = @db.prepare("INSERT INTO beginnings VALUES(?)")
	end

	def add_beginning(state)
		@add_beg_prep.execute(state)
	end

	def add_follow(lead, follow)
		@add_freq_prep.execute(lead, follow)
	end

	def single_transaction(&block)
		@db.transaction {
			block.call
		}
	end

	def get_beginning
		return @db.get_first_row(
			"SELECT * FROM beginnings " +
			"ORDER BY RANDOM() " +
			"LIMIT 1").join.split
	end

	def get_follow(state)
		return @db.get_first_row(
			"SELECT follow FROM freq " +
			"WHERE lead = ? " +
			"ORDER BY RANDOM() " +
			"LIMIT 1", state)
	end

	def clear
		drop_tables
		init_db
	end

	def vacuum
		before = File.size(DB_FILE)
		@db.execute("VACUUM beginnings")
		@db.execute("VACUUM freq")
		after = File.size(DB_FILE)
		return before - after
	end

private

	def db_empty?
		begin
			@db.execute("SELECT COUNT(*) FROM freq")
			return false
		rescue
			return true
		end
	end

	def init_db
		@db.execute("CREATE TABLE beginnings(lead varchar(64))")
		@db.execute("CREATE TABLE freq(lead varchar(64), follow varchar(64))")
		@db.execute("CREATE INDEX ilead ON freq (lead)")
	end

	def drop_tables
		@db.execute("DROP TABLE beginnings");
		@db.execute("DROP TABLE freq");
	end

end

# A sentence-parsing markov chain that can generate new sentences.
class EnglishMC
	def initialize(impl)
		@impl = impl
		@order = impl.order
	end

	def add_text(text)
		@impl.single_transaction {
			# Make sure each line ends with some sentence terminator.
			text.gsub!(/[\n\r]+/m, " . ")
			text << "." if text[-1,1] != "."
			seps = /(https?:\/\/\S+|[.!?]($|\s))/
			sentence = ""
			text.split(seps).grep(/\S/).each { |p|
				if seps =~ p
					add_sentence(sentence, p)
					sentence = ""
				else
					sentence += p
				end
			}
		}
	end

	def generate_sentence
		beg = @impl.get_beginning
		return generate_sentence_from(beg) if beg[0]
	end

	def generate_sentence_from(beginning)
		res = beginning
		loop do
			unless nw = next_word_for(res[-@order, @order])
				return res[0..-2].join(' ') + res.last
			end
			res << nw
		end
		return res
	end

private

	def add_sentence(str, terminator)
		words = str.scan(is_word)
		return unless words.size >= @order # Ignore short sentences.
		words[0][0..0] = words[0][0..0].upcase # Capitalize sentence.
		words << terminator
		buf = []
		words.each do |w|
			buf << w
			if buf.size >= @order + 1
				lead = buf[0..-2]
				follow = buf[-1]
				@impl.add_follow(lead.join(' '), follow)
				buf.shift
			end
		end
		beg = words[0, @order]
		@impl.add_beginning(beg.join(' '))
	end

	def next_word_for(words)
		row = @impl.get_follow(words.join(' '))
		if row.nil?
			return nil
		else
			return row.join
		end
	end

	def is_word
		if @order == 1
			return /[a-zA-Z0-9$,'-_]+/
		elsif @order == 2
			return /[a-zA-Z0-9$,'-_:;\/]+/
		else
			return /[a-zA-Z0-9$,'"-_:;\/\(\)]+/
		end
	end
end

class Markov < RubotPlugin
	@@actions = [
#		[/^:generate (\d+)/i, :generate_x],
#		[/^:generate/i, :generate],
		[/^:populate/i, :populate],
#		[/^:vacuum/i, :vacuum],
		[/^:replyrate! (\d+)/i, :set_replyrate],
		[/^:replyrate\?/i, :get_replyrate],
	]

	def initialize
		super
		@working = false
		@cooldown = IRCCooldown.new(self, 3,
			"Please wait %s more second%s to generate a sentence.")
		@replyrate = 1
		@replies = 0
		@populated = false
#		@backend = SqliteMC.new(1)
		@backend = MemMC.new(1)
		@mc = EnglishMC.new(@backend)
	end

	def on_privmsg(user, source, msg)
		return if @working
		jumped = RegexJump::jump(@@actions, self, msg, [user, source])
		add_line(rm_nicks(msg)) if not jumped and valid_line(msg)
		handle_autoreply(user, source, msg)
		@cooldown.trigger_now if jumped # For long operations.
	end

	def handle_autoreply(user, source, msg)
		if rand(100) < @replyrate
			@replies += 1
		end
		if @replies > 0 and @cooldown.trigger
			words = msg.split
			word = words[rand(words.size)]
			sent = @mc.generate_sentence_from([word])
			if sent
				sent[0..0] = sent[0..0].upcase # Capitalize sentence.
				@replies -= 1
				say(source, put_nicks(sent, user.nick))
			end
		end
	end

	def generate(user, source)
		return unless @cooldown.trigger_err(source)
		sent = @mc.generate_sentence
		say(source, put_nicks(sent, user.nick)) if sent
	end

	def generate_x(user, source, x)
		return if @working
		return unless @cooldown.trigger_err(source)
		work {
			track_time(source) {
				x.times { @mc.generate_sentence }
			}
		}
	end

	def populate(user, source)
		return if @populated
		work {
			track_time(source) {
				say(source, "Constructing database...")
				@backend.clear
				Dir.glob("privmsg_logs/*.txt").each do |file|
					@mc.add_text(IO.read(file))
				end
				say(source, "Finished.")
				@populated = true
			}
		}
	end

	def vacuum(user, source)
		if not @backend.respond_to? :vacuum
			say(source, "Current markov backend does not need vacuuming.")
			return
		end
		work {
			track_time(source) {
				say(source, "Vacuuming database...")
				reduced = @backend.vacuum
				say(source, "Reduced database size by #{reduced} bytes.")
			}
		}
	end

	def set_replyrate(user, source, rate)
		@replyrate = rate
		say(source, "Reply rate set to #{rate}%.")
	end

	def get_replyrate(user, source)
		say(source, "Reply rate is currently at #{@replyrate}%.")
	end

private

	NICK_SUB = "::NICK::"

	def rm_nicks(str)
		Users.each do |nick, user|
			str.gsub!(nick, NICK_SUB)
		end
		return str
	end

	def put_nicks(str, nick)
		return str.gsub(NICK_SUB, nick)
	end

	# Work in a background thread so we don't disconnect if we take too long, and
	# block all other calls to the database.
	def work(&block)
		Thread.new {
			@working = true
			block.call
			@working = false
		}
	end

	# Print the time a possibly long-standing operation takes.
	def track_time(source, &block)
		before = Time.now
		block.call
		after = Time.now
		say(source, "Took #{after-before} seconds.")
	end

	def valid_line(msg)
		# Only accept ASCII lines without NULLs or IRC control characters.
		return !msg.match(/[\x00\x01\x80-\xff]/)
	end

	def add_line(msg)
		open("privmsg_logs/#{@client.nick}.txt", "a") do |f|
			f.puts(msg)
		end
		@mc.add_text(msg)
	end
end

