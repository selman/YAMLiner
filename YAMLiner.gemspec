# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "YAMLiner/version"

Gem::Specification.new do |s|
  s.name        = "YAMLiner"
  s.version     = YAMLiner::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Selman ULUG"]
  s.email       = ["selman.ulug@gmail.com"]
  s.homepage    = "http://github.com/selman/YAMLiner"
  s.summary     = %q{inline YAML CRUD operations}
  s.description = %q{Simple gem that supplies inline YAML CRUD operations that usable by all kind of text files.}

  s.add_development_dependency('rspec', '~> 2.0.1')

  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc']
  s.rdoc_options << '--title' << "YAMLiner #{YAMLiner::VERSION}" <<
    '--main' << 'README.rdoc'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
end
