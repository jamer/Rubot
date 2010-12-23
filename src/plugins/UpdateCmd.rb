class UpdateCmd < RubotPlugin
	def privmsg(user, reply_to, message)
		if message =~ /^:update/i
			responces = Sources.update ? @@update_success : @@update_fail
			say reply_to, responces.random
			return true
		end
		return false
	end

	@@update_success = [
		"Updated.",
		"Now up to date.",
		"Ahh! I missed that update. Thanks for noticing.",
		"Let me pick that up...",
		"I can't believe I let that piece of code slip out of my notice!",
	]

	@@update_fail = [
		"Already at latest revision.",
		"Already up to date.",
		"Nothing new worth reporting, sir.",
		"Don't touch me, I'm perfect.",
	]

end

