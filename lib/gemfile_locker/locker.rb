require 'bundler'

module GemfileLocker
  class Locker < GemfileProcessor
    SEGMENTS_COUNT = {
      major: 1,
      minor: 2,
      patch: 3,
      full: 100,
    }.freeze

    attr_reader :lockfile

    def initialize(lockfile, *args)
      @lockfile = lockfile
      super(*args)
    end

    def bundler_specs
      @bundler_specs ||= Bundler::LockfileParser.new(lockfile).specs
    end

    def process_gem(gem_entry)
      name = gem_entry.name
      spec = bundler_specs.find { |x| x.name == name }
      return unless spec
      gem_entry.lock(version: prepare_version(spec.version), git_ref: prepare_git_ref(spec))
    end

    def skip_gem?(gem_entry)
      super || gem_entry.locked? && !options[:force]
    end

    private

    def prepare_version(version)
      if options[:loose]
        segments = version.segments.take(SEGMENTS_COUNT[options[:loose].to_sym])
        "~> #{segments.join('.')}"
      else
        version.to_s
      end
    end

    def prepare_git_ref(spec)
      if spec.source.is_a?(Bundler::Source::Git)
        spec.source.options['ref'] || spec.source.revision[0...7]
      end
    end
  end
end
