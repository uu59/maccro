require_relative '../code_range'

module Maccro
  module DSL
    module ASTNodeWrapper
      def children
        @child_nodes ||= super
      end

      def to_code_range
        CodeRange.from_node(self)
      end

      def match?(node)
        return false unless node.is_a?(ASTNodeWrapper)
        return false if node.type != self.type
        self.children.each_with_index do |c, i|
          if c.is_a?(ASTNodeWrapper)
            return false unless c.match?(node.children[i])
          else
            return false unless c == node.children[i]
          end
        end
        # same type, all children match with others
        true
      end

      def capture(ast, placeholders)
        self.children.each_with_index do |c, i|
          if c.is_a?(ASTNodeWrapper)
            c.capture(node.children[i], placeholders)
          end
        end
      end
    end

    class Node
      attr_reader :name, :first_lineno, :first_column, :last_lineno, :last_column

      include ASTNodeWrapper

      def initialize(name, code_range)
        @name = name
        @code_range = code_range
        @first_lineno = code_range.first_lineno
        @first_column = code_range.first_column
        @last_lineno = code_range.last_lineno
        @last_column = code_range.last_column
      end

      def to_code_range
        @code_range
      end

      def children
        []
      end

      def capture(ast, placehodlers)
        placeholders[@name] = ast.to_code_range
      end
    end

    class NodeGroup < Node
      def match?(node)
        subtypes.any?{|s| s.match?(node) }
      end
    end
  end
end