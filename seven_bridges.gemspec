# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'seven_bridges/version'

Gem::Specification.new do |spec|
  spec.name          = 'seven_bridges'
  spec.version       = SevenBridges::VERSION
  spec.authors       = ['Scott Speidel', 'Michael Jewell', 'Stanley Fung']
  spec.email         = ['scottspeidel@gmail.com', 'michaeljewell9911@gmail.com']

  spec.summary       = 'Tool to help understand the relationships between ruby methods'
  spec.description   = ''
  spec.homepage      = 'https://github.com/appfolio/seven_bridges'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_dependency 'neo4j'
end
