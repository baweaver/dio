module Dio
  module PublicApi
    # Treats `[]` like an alternative constructor and forwards to `DiveForwarder`
    #
    # @param ... [Any]
    #   Forwarded params
    #
    # @return [Dio::DiveForwarder]
    #   Dio pattern matching interface
    def [](...) = Dio::DiveForwarder.new(...)
  end
end
