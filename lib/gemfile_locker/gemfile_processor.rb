require 'parser'
require 'parser/current'
require 'gemfile_locker/gem_entry'

module GemfileLocker
  class GemfileProcessor
    class Rewriter < Parser::TreeRewriter
      def rewrite(*args, &block)
        @rewrite_block = block
        super(*args)
      end

      def on_send(node)
        children = node.children
        return unless children[0].nil? && node.children[1] == :gem
        gem_entry = GemEntry.new(self, node)
        @rewrite_block[gem_entry]
      end
    end

    attr_reader :path, :options

    def initialize(options = {})
      @options = options
    end

    def call(string)
      buffer = Parser::Source::Buffer.new('(Gemfile)')
      buffer.source = string
      parser = Parser::CurrentRuby.new
      ast = parser.parse(buffer)
      Rewriter.new.rewrite(buffer, ast) do |gem_entry|
        process_gem(gem_entry) unless skip_gem?(gem_entry)
      end
    end

    def skip_gem?(gem_entry)
      if options[:only]
        !options[:only].include?(gem_entry.name)
      elsif options[:except]
        options[:except].include?(gem_entry.name)
      end
    end

    def process_gem(_name, _data)
      raise 'Abstract method'
    end
  end
end
