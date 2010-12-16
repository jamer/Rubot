class Slap < RubotPlugin
	# Slap people around with some fish. Warning: Some of the rare and unique
	# specimens of fish that we've collected may not resemble any fish you are
	# familiar with. But take my word, they *are* fish.

	def initialize
		@fish = [
			"a large 4r7a8i9n3b2o12w 6t4r7o8u9t3",
			"some freshly baked home-made cookies :3",
			"some cake",
			"a pink Macintosh",
			"a tire iron",
			"a series of tubes called the Internets",
			"a hobbit",
			"a direct business cable ethernet line",
			"an oversized tiger shark",
			"a CrunchBang Linux .iso file",
			"an extra extra sugared cup of coffee",
			"Mars",
			"an IRC server",
			"an IRC network",
			"a netop",
			"itself",
			"a coupon for the local supermarket",
			"a fluffy pillow",
			"a Wikileaks cable",
			"a rented library book",
			"a glass of chocolate milk",
			"a wave of fake lag",
			"a wave of oreos",
			"a collection of overpriced stuffed animals",
			"an Oracle database",
			"an obscene Urban Dictionary definition",
			"a meme",
			"the car keys",
			"a half-filled glass",
			"a half-empty glass",
			"a meat pie",
			"SavetheinternetBot",
			"a milk jug",
			"Hades",
			"the Greek god, Dionysus",
			"the Mayan god, Kukulcan",
			"one thousand pascals",
			"a tweet from Twitter",
			"an experimental window manager",
			"a trombone",
			"a simili",
		]
	end

	def privmsg(user, reply_to, message)
		slap reply_to, message
		flinch reply_to if got_slapped message
	end

	def slap(reply_to, message)
		return unless match = message.match(/^slap[ \t]+(.+)/i)
		target = match[1]
		target = "itself" if target.downcase.include? @client.nick.downcase
		say reply_to,
				"slaps #{target} around a bit with #{@fish.choice}.", :action

		flinch reply_to if %w(himself herself itself).include? target
	end

	def got_slapped(message)
		message.include? "slaps #{@client.nick}"
	end

	def flinch(reply_to)
		say reply_to, "Ouch!"
	end
end

