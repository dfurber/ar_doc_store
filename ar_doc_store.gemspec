# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ar_doc_store/version'

Gem::Specification.new do |spec|
  spec.name          = "ar_doc_store"
  spec.version       = ArDocStore::VERSION
  spec.authors       = ["David Furber"]
  spec.email         = ["dfurber@gorges.us"]
  spec.summary       = %q{A document storage gem meant for ActiveRecord PostgresQL JSON storage.}
  spec.description   = %q{TODO: Write a longer description}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 4.0"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
