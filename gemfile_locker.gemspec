# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gemfile_locker/version'

Gem::Specification.new do |spec|
  spec.name          = 'gemfile_locker'
  spec.version       = GemfileLocker::VERSION
  spec.authors       = ['Max Melentiev']
  spec.email         = ['melentievm@gmail.com']

  spec.summary       = <<~TXT
    Tool to manage Gemfile. Lock and unlock all dependencies for safe `bundle update`.
  TXT
  spec.description = <<~TXT
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
  spec.required_ruby_version = '>= 2.4'

  spec.add_runtime_dependency 'bundler', '>= 1.13'
  spec.add_runtime_dependency 'parser', '~> 2.0'
  spec.add_runtime_dependency 'thor', '> 0.19', '< 2.0'

  spec.add_development_dependency 'rake', '~> 13.0'
end
