#!/usr/bin/ruby

# Loads mkmf which is used to make Makefiles for Ruby extensions.
require 'mkmf'

# Give it a name.
extension_name = "markov"

# The destination.
dir_config(extension_name)

# Do the work.
create_makefile(extension_name)

