# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "panache/version"

Gem::Specification.new do |s|
  s.name        = "panache"
  s.version     = Panache::VERSION
  s.authors     = ["Caleb Spare", "Daniel MacDougall"]
  s.email       = ["caleb@ooyala.com", "dmac@ooyala.com"]
  s.homepage    = ""
  s.summary     = %q{Create style checkers for various languages}
  s.description = <<-EOF
Panache is a simple way to create style checkers for various languages.
It does simple parsing of source files and then applies user-specified rules to detect style violations.
                  EOF

  s.rubyforge_project = "panache"
  s.required_ruby_version = ">= 1.9.2"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "colorize"
end
