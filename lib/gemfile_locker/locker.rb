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

    def process_gem(data)
      name = data[:name]
      locked = bundler_specs.find { |x| x.name == name }
      locked && set_gem_version(data, prepare_version(locked.version))
    end

    def skip_gem?(data)
      super || data[:version] && !options[:force]
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
  end
end
