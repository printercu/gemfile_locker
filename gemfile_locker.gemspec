# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gemfile_locker/version'

Gem::Specification.new do |spec|
  spec.name          = 'gemfile_locker'
  spec.version       = GemfileLocker::VERSION
  spec.authors       = ['Max Melentiev']
  spec.email         = ['melentievm@gmail.com']

  spec.summary       = <<-TXT
Tool to manage Gemfile. Lock and unlock all dependencies for safe `bundle update`.
TXT
  spec.description   = <<-TXT
GemfileLocker can lock all dependencies strictly or semi-strictly,
so it gets safe to run `bundle update` anytime.

It can unlock all dependencies so you can easily update to the latest versions.
TXT
  spec.homepage      = 'https://github.com/printercu/gemfile_locker'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
end
