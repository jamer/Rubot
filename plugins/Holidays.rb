class Holidays < RubotPlugin
	@@holidays = [
		[1,  1,  /happy new year'?s/i,           "Happy New Year's Day"],
		[2,  2,  /happy groundhog day/i,         "Happy Groundhog Day"],
		[2,  14, /happy valentine'?s/i,          "Happy Valentine's Day"],
		[3,  17, /happy saint patrick'?s/i,      "Happy Saint Patrick's Day"],
		[4,  1,  /happy april fool'?s/i,         "Happy April Fool's Day"],
		[5,  5,  /happy cinco de mayo/i,         "Happy Cinco de Mayo"],
		[7,  4,  /happy fourth of july/i,        "Happy Fourth of July"],
		[7,  4,  /happy independence day/i,      "Happy US Independence Day"],
		[10, 31, /happy halloween/i,             "Happy Hallow's Eve"],
		[12, 24, /(merry|happy) christmas eve/i, "Merry Christmas Eve"],
		[12, 25, /merry christmas/i,             "Merry Christmas"],
		[12, 25, /happy holidays/i,              "Happy holidays"],
		[12, 31, /happy new year's eve/i,        "Happy New Year's Eve"],
	]

	def initialize
		super
		@cooldown = Cooldown.new(1800)
	end

	def on_privmsg(user, source, msg)
		today = Date::today
		@@holidays.each do |month, day, watch_for, cheer|
			if today.month == month && today.day == day && watch_for.match(msg)
				return unless @cooldown.trigger
				say(source, "#{cheer}, #{user.nick}!")
			end
		end
	end
end

