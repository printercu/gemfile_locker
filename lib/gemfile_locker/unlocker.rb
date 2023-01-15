# frozen_string_literal: true

module GemfileLocker
  class Unlocker < GemfileProcessor
    attr_reader :lockfile

    def process_gem(gem_entry)
      gem_entry.unlock
    end
  end
end
