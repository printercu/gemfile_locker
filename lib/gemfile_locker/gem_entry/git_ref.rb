module GemfileLocker
  class GemEntry
    module GitRef
      def lock(options)
        git_ref = options[:git_ref]
        set_git_ref(git_ref) if git_ref && !has_git_tag?
        super
      end

      def unlock
        remove_git_ref
        super
      end

      def has_git_tag?
        git_option_nodes.any? { |pair| pair.children[0].children[0] == :tag }
      end

      def set_git_ref(ref) # rubocop:disable AccessorMethodName
        ref_node = ref_option_node
        return replace_string_node(ref_node.children[1], ref) if ref_node
        git_nodes = git_option_nodes
        insert_after_node = git_nodes.any? ? git_nodes.last : node.children.last
        quote = name_quote
        rewriter.insert_after(insert_after_node.loc.expression.end, ", ref: #{quote}#{ref}#{quote}")
      end

      def remove_git_ref
        ref_node = ref_option_node
        remove_node_with_comma(ref_node) if ref_node
      end

      protected

      def ref_option_node
        return unless options_node
        options_node.children.find do |pair|
          pair.children[0].to_sexp_array == [:sym, :ref]
        end
      end

      RELATED_OPTIONS = /\A(git*|branch|tag)\z/

      def git_option_nodes
        return [] unless options_node
        options_node.children.reverse.select do |pair|
          key_node = pair.children[0]
          next unless key_node.type == :sym
          RELATED_OPTIONS =~ key_node.children[0].to_s
        end
      end
    end
  end
end
