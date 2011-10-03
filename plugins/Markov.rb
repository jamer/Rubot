# Random sentence generator built using Markov chains

# Require C extension.
require './ext/markov'

# A sentence-parsing markov chain that can generate new sentences.
class MarkovChainer
	attr_reader :order, :beginnings, :freq

	def initialize(order)
		@order = order
		@beginnings = []
		@freq = {}
	end

	def add_text(text)
		# Make sure each line ends with some sentence terminator.
		text.gsub!(/[\n\r]+/m, " . ")
		text << "."
		seps = /(https?:\/\/\S+|[.!?]($|\s))/
		sentence = ""
		text.split(seps).grep(/\S/).each { |p|
			puts "TEXT TOKEN #{p}"
			if seps =~ p
				puts "ADDING SENTENCE"
				add_sentence(sentence, p)
				sentence = ""
			else
				if sentence == ""
					puts "ASSIGNING SENTENCE"
				else
					puts "APPENDING SENTENCE"
				end
				sentence += p
			end
		}
	end

	def generate_sentence
		res = @beginnings[rand(@beginnings.size)]
		return generate_sentence_from(res)
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
		words = str.scan(word_is)
		return unless words.size >= @order # Ignore short sentences.
		words[0][0..0] = words[0][0..0].upcase # Capitalize sentence.
		words << terminator
		buf = []
		words.each do |w|
			buf << w
			if buf.size >= @order + 1
				(@freq[buf[0..-2]] ||= []) << buf[-1]
				buf.shift
			end
		end
		@beginnings << words[0, @order]
	end

	def next_word_for(words)
		arr = @freq[words]
		arr && arr[rand(arr.size)]
	end

	def word_is
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
		[/^:generate/i, :generate],
	]

	def initialize
		super
		@cooldown = IRCCooldown.new(self, 3,
			"Please wait %s more second%s to generate a sentence.")
	end

	def on_privmsg(user, source, msg)
		jumped = RegexJump::jump(@@actions, self, msg, [source])
		add_line(msg) if not jumped and valid_line(msg)
	end

	def generate(source)
		return unless @cooldown.trigger_err(source)
		initialize_mc(source) if not defined?(@mc)
		say(source, @mc.generate_sentence)
	end

private

	def valid_line(msg)
		return !msg.match(/\x01/) && !msg.match(/[\x80-\xff]/)
	end

	def add_line(msg)
		@mc.add_text(msg) if defined?(@mc)
		open("privmsg_logs/#{@client.nick}.txt", "a") do |f|
			f.puts(msg)
		end
	end

	def initialize_mc(source)
		before = Time.now
		say(source, "Constructing initial data structures...")
		@mc = MarkovChain.new()
		Dir.glob("privmsg_logs/*.txt").each do |file|
			puts "Adding #{file}"
			@mc.add_text(IO.read(file))
		end
		after = Time.now
		say(source, "Took #{after-before} seconds.")
		@cooldown.trigger_now
	end
end

