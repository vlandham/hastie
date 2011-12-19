# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hastie/version', __FILE__)

Gem::Specification.new do |s|
  s.add_dependency "thor", "~> 0.14.6"
  s.add_dependency "grit", "~> 2.4.1"
  s.add_development_dependency "bundler", "~> 1.0"
  s.add_development_dependency "rdoc", "~> 3.9"
  s.add_development_dependency "rspec", "~> 2.3"
  s.add_development_dependency "simplecov", "~> 0.4"
  # s.add_development_dependency "ZenTest", "~> 4.5.0"
  # s.add_development_dependency "autotest-fsevent", "~> 0.2.5"
  # s.add_development_dependency "autotest-growl", "~> 0.2.9"
  s.authors = ['Jim Vallandingham']
  s.description = %q{}
  s.email = 'none@none.com'
  s.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.extra_rdoc_files = ['LICENSE', 'README.textile']
  s.files = `git ls-files`.split("\n")
  s.homepage = 'http://github.com/vlandham/hastie'
  s.name = 'hastie'
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')
  s.summary = s.description
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.version = Hastie::VERSION.dup
end

