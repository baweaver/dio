require 'delegate'

module Dio
  module Forwarders
    # Allows for Pattern Matching against arbitrary objects by wrapping them
    # in an interface that understands methods of deconstructing objects.
    #
    # **Approximating Deconstruction**
    #
    # As Ruby does not, by default, define `deconstruct` and `deconstruct_keys` on
    # objects this class attempts to approximate them.
    #
    # This class does, however, do something unique in treating `deconstruct_keys`
    # as a series of calls to sent to the class and its "nested" values.
    #
    # **Demonstrating Nested Values**
    #
    # Consider an integer:
    #
    # ```ruby
    # Dio[1] in { succ: { succ: { succ: 4 } } }
    # # => true
    # ```
    #
    # It has no concept of deconstruction, except in that its `succ` method returns
    # a "nested" value we can match against, allowing us to "dive into" the
    # object, diving us our namesake Dio, or "Dive Into Object"
    #
    # **Delegation**
    #
    # As with most monadic-like design patterns that add additional behavior by
    # wrapping objects we need to extract the value at the end to do anything
    # particularly useful.
    #
    # By adding delegation to this class we have a cheat around this in that
    # any method called on the nested DiveForwarder instances will call through
    # to the associated base object instead.
    #
    # I am not 100% sold on this approach, and will consider it more in the
    # future.
    #
    # @author [baweaver]
    #
    class BaseForwarder < ::Delegator
      # Wrapper for creating a new Forwarder
      NEW_DIVE = -> v { new(v) }

      # Creates a new delegator that understands the pattern matching interface
      #
      # @param base_object [Any]
      #   Any object that does not necessarily understand pattern matching
      #
      # @return [DiveForwarder]
      def initialize(base_object)
        @base_object = base_object
      end

      # Approximation of an Array deconstruction:
      #
      # ```ruby
      # [1, 2, 3] in [*, 2, *]
      # ```
      #
      # Attempts to find a reasonable interface by which to extract values
      # to be matched. If an object that knows how to match already is sent
      # through wrap its child values for deeper matching.
      #
      # Current interface will work with `to_a`, `to_ary`, `map`, and values
      # that can already `deconstruct`. If others are desired please submit a PR
      # to add them
      #
      # @raises [Dio::Errors::NoDeconstructionMethod]
      #   If no method of deconstruction exists, an exception is raised to
      #   communicate the proper interface and note the abscense of a current one.
      #
      # @return [Array[DiveForwarder]]
      #   Values lifted into a Dio context for further matching
      def deconstruct
        return @base_object.deconstruct.map!(&NEW_DIVE) if @base_object.respond_to?(:deconstruct)

        return @base_object.to_a.map!(&NEW_DIVE) if @base_object.respond_to?(:to_a)
        return @base_object.to_ary.map!(&NEW_DIVE) if @base_object.respond_to?(:to_ary)
        return @base_object.map(&NEW_DIVE) if @base_object.respond_to?(:map)

        raise Dio::Errors::NoDeconstructionMethod
      end

      # Approximates `deconstruct_keys` for Hashes, except in adding `Qo`-like
      # behavior that allows to treat objects as "nested values" through their
      # method calls.
      #
      # **Deconstructing an Object**
      #
      # In `Qo` one could match against an object by calling to its methods using
      # `public_send`. This allowed one to "dive into" an object through a series
      # of method calls, approximating a Hash pattern match.
      #
      # **Native Behavior**
      #
      # If the object already responds to `deconstruct_keys` this method will
      # behave similarly to `deconstruct` and wrap its values as new
      # `DiveForwarder` contexts.
      #
      # @param keys [Array]
      #   Keys to be extracted from the object
      #
      # @return [Hash]
      #   Deconstructed keys pointing to associated values extracted from a Hash
      #   or an Object. Note that these values are matched against using `===`.
      def deconstruct_keys(keys)
        if @base_object.respond_to?(:deconstruct_keys)
          @base_object
            .deconstruct_keys(keys)
            .transform_values!(&NEW_DIVE)
        else
          keys.to_h { |k| @base_object.public_send(k).then { |v| [k, NEW_DIVE[v]] } }
        end
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
