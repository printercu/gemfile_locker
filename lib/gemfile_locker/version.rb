# frozen_string_literal: true

module GemfileLocker
  VERSION = '0.4.1'

  def self.gem_version
    Gem::Version.new VERSION
  end
end
