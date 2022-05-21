# frozen_string_literal: true

require_relative "lib/pronto/fasterer/version"

Gem::Specification.new do |spec|
  spec.name = "pronto-fasterer"
  spec.version = Pronto::FastererVersion::VERSION
  spec.authors = ["fargelus"]
  spec.email = ["ddraudred@gmail.com"]

  spec.summary = "Pronto runner for fasterer gem"
  spec.homepage = "https://github.com/fargelus/pronto-fasterer"
  spec.required_ruby_version = ">= 2.6.0"

  spec.files = Dir.glob("lib/**/*")

  spec.require_paths = ["lib"]

  spec.add_dependency "pronto"
  spec.add_dependency "fasterer"
end
