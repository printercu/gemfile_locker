# frozen_string_literal: true

module SpecHelpers
  module Fixtures
    def read_fixture(*parts)
      File.read(fixture_file_path(*parts))
    end

    def fixture_file_path(*parts)
      fixtures_root.join(*parts)
    end

    def fixtures_root
      @fixtures_root ||= GEM_ROOT.join 'spec', 'fixtures'
    end

    RSpec.configure { |x| x.include self }
  end
end
