module Dio
  # Public API for Dio
  #
  # @author [baweaver]
  # @since 0.0.1
  module PublicApi
    # Treats `[]` like an alternative constructor and forwards to `DiveForwarder`
    #
    # @param ... [Any]
    #   Forwarded params
    #
    # @return [Dio::DiveForwarder]
    #   Dio pattern matching interface
    def [](...) = Dio::Forwarders::BaseForwarder.new(...)

    # Dynamic Forwarder, uses `public_send` for Hash forwarding
    #
    # @param ... [Any]
    #   Arguments to match against
    #
    # @return [Dio::Forwarders::BaseForwarder]
    def dynamic(...) = Dio::Forwarders::BaseForwarder.new(...)

    # Attribute Forwarder, extracts `attr_*` methods to match against
    #
    # @param ... [Any]
    #   Arguments to match against
    #
    # @return [Dio::Forwarders::AttributeForwarder]
    def attribute(...) = Dio::Forwarders::AttributeForwarder.new(...)

    # String Hash Forwarder, treats a String Hash like a Symbol Hash for
    # matching against.
    #
    # @param ... [Any]
    #   Arguments to match against
    #
    # @return [Dio::Forwarders::StringHashForwarder]
    def string_hash(...) = Dio::Forwarders::StringHashForwarder.new(...)
  end
end
