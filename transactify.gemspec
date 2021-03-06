# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'transactify/version'

Gem::Specification.new do |spec|
  spec.name          = "transactify"
  spec.version       = Transactify::VERSION
  spec.authors       = ["Igor Kasyanchuk"]
  spec.email         = ["igorkasyanchuk@gmail.com"]

  spec.summary       = %q{Wrap your code in DB transactions.}
  spec.description   = %q{Transactify gem can run your methods in database transaction. Previously you had to wrap you code in `ActiveRecord::Base.transaction do .. end` but now it can be done in much more simpler way.}
  spec.homepage      = "https://github.com/igorkasyanchuk/transactify"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0'

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "activerecord", "> 0"
  spec.add_development_dependency "rspec", "> 0"
  spec.add_development_dependency "pry", "> 0"
  spec.add_development_dependency "simplecov", "> 0"
  spec.add_development_dependency 'sqlite3', "> 0"
end