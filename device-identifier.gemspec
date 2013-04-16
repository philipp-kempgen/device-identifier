# -*- encoding: utf-8 -*-

lib_dir = File.expand_path( '../lib/', __FILE__ )
$LOAD_PATH.unshift( lib_dir )

require 'dev-id/version'

spec = Gem::Specification.new { |s|
	s.name         = 'device-identifier'
	s.version      = ::DevId::VERSION_STR
	s.summary      = "Models for device identifiers."
	s.description  = "Models for device identifiers, e.g. MAC addresses for hardware clients and arbitrary identifier strings for software clients."
	s.author       = "Philipp Kempgen"
	s.homepage     = 'https://github.com/philipp-kempgen/device-identifier'
	s.platform     = Gem::Platform::RUBY
	s.require_path = 'lib'
	s.executables  = []
	s.files        = Dir.glob( '{lib,bin}/**/*' ) + %w(
		README.md
	)
	
	s.add_dependency "activemodel", "~> 3.2" #"~> 3.2.12"
	
	# The provided functionality might more or less just as well
	# have been built using one of the Gems in following instead
	# of "activemodel":
	#s.add_dependency "supermodel", "~> 0.1.6"
	#s.add_dependency "simple_model", "~> 1.2.8"
	#s.add_dependency "basic_model", "~> 0.3.2"
	#s.add_dependency "prequel", "~> 0.0.1"
}


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# End:

