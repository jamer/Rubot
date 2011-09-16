$:.push File.expand_path("../lib", __FILE__)
require "rubot/version.rb"

Gem::Specification.new do |s|
	s.name = "Rubot"
	s.version = Rubot::VERSION
	s.authors = ["Paul Merrill"]
	s.email = ["napalminc@gmail.com"]
	s.homepage = ""
	s.summary = %q{TODO: Write a gem summary}
	s.description = %q{TODO: Write a gem description}

	s.files = `git ls-files`.split("\n")
	s.test_files = `git ls-files -- test/*`.split("\n")
	s.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f) }
	s.require_paths = ["lib"]
end

