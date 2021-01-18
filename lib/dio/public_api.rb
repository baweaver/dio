module Dio
  module PublicApi
    # Treats `[]` like an alternative constructor and forwards to `DiveForwarder`
    #
    # @param ... [Any]
    #   Forwarded params
    #
    # @return [Dio::DiveForwarder]
    #   Dio pattern matching interface
    def [](...) = Dio::Forwarders::BaseForwarder.new(...)

    def dynamic(...)     = Dio::Forwarders::BaseForwarder.new(...)
    def attrs(...)       = Dio::Forwarders::AttributeForwarder.new(...)
    def string_hash(...) = Dio::Forwarders::StringHashForwarder.new(...)
  end
end
