require 'delegate'

module Dio
  module Forwarders
    # A more controlled forwarder that targets only `attr_` type methods like
    # `attr_reader` and `attr_accessor`. These attributes are found by diffing
    # instance variables and method names to find generated accessor methods.
    #
    # It should be noted that this could be faster if there was an assumption
    # of purity at the time of the match. I may make another variant for that.
    #
    # @author [baweaver]
    # @since 0.0.3
    #
    class AttributeForwarder < BaseForwarder
      def initialize(base_object)
        ivars = Set.new base_object
          .instance_variables
          .map { _1.to_s.delete('@').to_sym }

        all_methods = Set.new base_object.methods

        @attributes = ivars.intersection(all_methods)

        super
      end

      # Deconstructs from a list of attribute names, wrapping each value
      # in a new dive in case the pattern match goes further than one level.
      #
      # @return [Array]
      def deconstruct
        @attributes.map { NEW_DIVE[@base_object.send(_1)] }
      end

      # Deconstructs attributes from an object, wrapping each value in a new
      # dive in case the pattern match goes further than one level.
      #
      # @param keys [Array]
      #   Keys to be extracted, diffed against possible attributes
      #
      # @raises [Dio::Errors::UnknownAttributesProvided]
      #   Guard against unknown attributes without an associated accessor
      #   method
      #
      # @return [Hash]
      def deconstruct_keys(keys)
        key_set      = Set.new(keys)
        unknown_keys = key_set - @attributes

        if unknown_keys.any?
          raise Dio::Errors::UnknownAttributesProvided.new(unknown_keys)
        end

        known_keys = @attributes.intersection(key_set)

        known_keys.to_h { [_1, NEW_DIVE[@base_object.send(_1)]] }
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
