# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name          = "pg-enum"
  s.version       = "0.0.1"
  s.author        = "Francesco Rodríguez"
  s.email         = "frodsan@protonmail.com"

  s.summary       = "Adds support for Postgres (enum)erated types to Active Record"
  s.description   = s.summary
  s.homepage      = "https://github.com/frodsan/pg-enum"
  s.license       = "MIT"

  s.files      = Dir["LICENSE", "README.md", "lib/**/*.rb"]
  s.test_files = Dir["test/**/*.rb"]

  s.add_dependency "activerecord", ">= 4.2"
  s.add_dependency "pg", ">= 0.18"
  s.add_dependency "railties", ">= 4.2"

  s.add_development_dependency "bundler", "~> 1.15"
  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "rubocop", "~> 0.49"
  s.add_development_dependency "rake", "~> 12.0"
end
