module GemfileLocker
  class GemEntry
    module Versions
      EXTRA_VERSION_REGEXP = /\A[><]/

      def lock(**options)
        version = options[:version]
        set_version(version) if version
        super
      end

      def unlock
        remove_version
        super
      end

      def locked?
        version_nodes.any?
      end

      def set_version(version) # rubocop:disable AccessorMethodName
        version_nodes = self.version_nodes
        if version_nodes.any?
          replace_string_node(version_nodes.first, version)
        else
          quote = name_quote
          rewriter.insert_after(node.children[2].loc.end, ", #{quote}#{version}#{quote}")
        end
      end

      def remove_version
        # If multiple version strings are given, keep that which start with `>, >=, <, <=`.
        version_nodes = self.version_nodes(strict: ->(versions) { versions.size > 1 })
        version_nodes.each do |arg_node|
          remove_node_with_comma(arg_node)
        end
      end

      protected

      def version_nodes(strict_if: nil, strict: !strict_if)
        result = node.children.drop(3).select { |arg_node| arg_node.type == :str }
        if strict_if && strict_if[result] || strict
          result = result.reject do |arg_node|
            EXTRA_VERSION_REGEXP =~ arg_node.children[0]
          end
        end
        result
      end
    end
  end
end
