lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "maxima/version"

Gem::Specification.new do |spec|
  spec.name          = "rb_maxima"
  spec.version       = Maxima::VERSION
  spec.authors       = ["Daniel Ackerman"]
  spec.email         = ["daniel.joseph.ackerman@gmail.com"]

  spec.summary       = %q{A gem that allows for mathematical calculations using the open source Maxima library!}
  spec.description   = %q{Ruby developers have, for as long as I can remember, had a disheveled heap of scientific and mathematical libraries - many of which operate in pure ruby code. Given a problem we either kludge together some cobbled mess or turn to Python/R/etc. And to this I say no more! rb_maxima allows a ruby developer to directly leverage the unbridled power of the open source, lisp powered, computer algebra system that is Maxima!}
  # spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = Dir['lib/**/*.rb']

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'pry', "~> 0.10"
  spec.add_development_dependency 'rspec', "~> 3.0"
  spec.add_development_dependency 'guard', "~> 2.0"
  spec.add_development_dependency 'guard-rspec', "~> 4.7"
  spec.add_development_dependency 'pry-nav', "~> 0.2"
  spec.add_development_dependency 'simplecov', "~> 0.16"

  spec.add_dependency "numo-gnuplot", "~> 0.2"
end
