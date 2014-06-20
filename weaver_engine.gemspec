# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'weaver_engine/version'

Gem::Specification.new do |spec|
  spec.name          = "weaver_engine"
  spec.version       = WeaverEngine::VERSION
  spec.authors       = ["Nathanael Jones"]
  spec.email         = ["nathanael.jones@gmail.com"]
  spec.summary       = %q{Multiplayer text-based game execution engine}
  spec.description   = %q{Multiplayer text-based game execution engine}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rufus-lua"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
