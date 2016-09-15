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
  spec.description   = %q{Provides an easy way to do something that is possible in Rails but still a bit close to the metal using store_accessor: create typecasted, persistent attributes that are not columns in the database but stored in the JSON "data" column. Also supports infinite nesting of embedded models.}
  spec.homepage      = "https://github.com/dfurber/ar_doc_store"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord" #, "~> 4.0"
  spec.add_dependency "pg", "~> 0.17"
  # spec.add_dependency "hashie", ">=3.4.0"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
