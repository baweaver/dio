require 'delegate'

module Dio
  module Forwarders
    # Pattern Matching relies on Symbol keys for Hash matching, but a significant
    # number of Ruby Hashes are keyed with Strings. This forwarder addresses
    # that issue by transforming String keys into Symbols for the sake of matching
    # against them:
    #
    # ```ruby
    # Dio.string_hash({ 'a' => 1 }) in { a: 1 }
    # # => true
    # ```
    #
    # @author [baweaver]
    # @since 0.0.3
    #
    class StringHashForwarder < BaseForwarder
      # Wrapper for creating a new Forwarder
      NEW_DIVE = -> v { new(v) }

      # If an Array is provided from nested values we may want to match against
      # it as well. Wrap the values in new forwarders to accomodate this.
      #
      # @raises [Dio::Errors::NoDeconstructionMethod]
      #   Debating on this one. If the base is not an Array it complicates how
      #   to Array match against a Hash. Raise an error for now, consider
      #   revisiting later.
      #
      # @return [Array]
      def deconstruct
        return @base_object.map(&NEW_DIVE) if @base_object.is_a?(Array)

        # Debating on this one
        raise Dio::Errors::NoDeconstructionMethod
      end

      # Extracts keys from a Hash by treating the provided keys like Strings.
      # Return the base object with keys transformed to Symbols to accomodate
      # pattern matching features.
      #
      # @param keys [Array]
      #   Keys to extract
      #
      # @return [Hash]
      def deconstruct_keys(keys)
        @base_object
          .slice(*keys.map(&:to_s))
          .to_h { |k, v| [k.to_sym, NEW_DIVE[v]] }
      end

      # Unwrapped context, aliased afterwards to use Ruby's delegator interface
      #
      # @return [Any]
      #   Originally wrapped object
      def value
        @base_object
      end

      alias_method :__getobj__, :value
    end
  end
end
