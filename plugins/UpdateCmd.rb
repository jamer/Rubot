class UpdateCmd < RoobotPlugin
	def privmsg_listener(nick, realname, host, source, message)
		if message =~ /^>\s*update/i
			responces = Sources.update ? @@update_success : @@update_fail
			say source, responces.random
			return true
		end
		return false
	end

	@@update_success = [
		"Updated.",
		"Now up to date.",
		"Ahh! I missed that update. Thanks for noticing.",
	]

	@@update_fail = [
		"Already at latest revision.",
		"Already up to date.",
		"Nothing new worth reporting, sir.",
		"Don't touch me, I'm perfect.",
	]

end

