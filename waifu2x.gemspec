# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'waifu2x/version'

Gem::Specification.new do |spec|
  spec.name          = "waifu2x"
  spec.version       = Waifu2x::VERSION
  spec.authors       = ["Nihad Abbasov"]
  spec.email         = ["nihad@42na.in"]

  spec.summary       = %q{Ruby wrapper and CLI for waifu2x}
  spec.description   = %q{Noise Reduction and 2x Upscaling for anime style images}
  spec.homepage      = "https://github.com/NARKOZ/waifu2x"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'typhoeus'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "minitest"
end
