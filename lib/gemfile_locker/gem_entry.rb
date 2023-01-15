# frozen_string_literal: true

module GemfileLocker
  class GemEntry
    attr_reader :rewriter, :node

    def initialize(rewriter, node)
      @rewriter = rewriter
      @node = node
    end

    def name
      node.children[2].children[0]
    end

    # Overriden in prepended modules.
    def lock(**options); end

    # Overriden in prepended modules.
    def unlock; end

    require 'gemfile_locker/gem_entry/versions'
    prepend Versions

    require 'gemfile_locker/gem_entry/git_ref'
    prepend GitRef

    protected

    # Node with gem options, if present.
    def options_node
      result = node.children.last
      result if result.type == :hash
    end

    # Change content of string, keeping quoting style.
    def replace_string_node(target, value)
      quote = target.loc.begin.source
      rewriter.replace(target.loc.expression, "#{quote}#{value}#{quote}")
    end

    # Remove node with preceding comma.
    def remove_node_with_comma(target)
      expression = target.loc.expression
      comma_pos = expression.source_buffer.source.rindex(',', expression.begin_pos)
      rewriter.remove(expression.with(begin_pos: comma_pos))
    end

    # Quote style used in name of gem.
    def name_quote
      node.children[2].loc.begin.source
    end
  end
end
