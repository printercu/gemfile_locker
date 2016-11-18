module GemfileLocker
  class GemfileProcessor
    GEM_LINE_REGEX = /
      ^
      (?<prefix>\s*gem\s*["'])
      (?<name>[^'"]+)
      (?<name_quote>['"])
      (?<version_section>
        (?<version_prefix>\s*,\s*['"])
        (?<version>[^'"]*)
        (?<version_quote>['"])
      )?
      (?<suffix>,?.*)?
      $
    /x
    GEM_MATCH_FIELDS = %i(
      prefix
      name
      name_quote
      version_prefix
      version
      version_quote
      suffix
    ).freeze

    attr_reader :path, :options

    def initialize(options = {})
      @options = options
    end

    def call(string)
      process_gems(string) do |data|
        process_gem(data) unless skip_gem?(data)
      end
    end

    def skip_gem?(data)
      if options[:only]
        !options[:only].include?(data[:name])
      elsif options[:except]
        options[:except].include?(data[:name])
      end
    end

    def process_gems(string)
      string.gsub(GEM_LINE_REGEX) do
        match = Regexp.last_match
        data = GEM_MATCH_FIELDS.map { |x| [x, match[x]] }.to_h
        result = yield data
        result ||= data
        GEM_MATCH_FIELDS.map { |x| result[x] }.join
      end
    end

    def process_gem(_name, _data)
      raise 'Abstract method'
    end

    def set_gem_version(data, version)
      data = data.dup
      if version
        data[:version_prefix] ||= ", #{data[:name_quote] || "'"}"
        data[:version_quote] ||= data[:name_quote] || "'"
        data[:version] = version
      else
        %i(
          version_prefix
          version
          version_quote
        ).each { |x| data.delete(x) }
      end
      data
    end
  end
end
