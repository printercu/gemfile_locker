module GemfileLocker
  class Unlocker < GemfileProcessor
    attr_reader :lockfile

    def process_gem(data)
      set_gem_version(data, nil)
    end
  end
end
