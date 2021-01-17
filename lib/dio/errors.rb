module Dio
  module Errors
    # Error raised when no deconstruction method is available on an object being
    # treated like an Array deconstruction.
    #
    # @author [baweaver]
    # @since 0.0.1
    class NoDeconstructionMethod < StandardError
      # Error message
      MSG = 'Object provided no method of deconstruction (to_a, to_ary, map, Enumerable)'

      def initialize(msg=MSG) = super
    end
  end
end
