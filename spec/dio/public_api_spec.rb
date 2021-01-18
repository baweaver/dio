require 'spec_helper'

RSpec.describe Dio::PublicApi do
  describe '.[]' do
    it 'creates a new Forwarder' do
      expect(Dio[1]).to be_a(Dio::Forwarders::BaseForwarder)
    end
  end

  describe '.dynamic' do
    it 'creates a Dynamic forwarder' do
      expect(Dio.dynamic(1)).to be_a(Dio::Forwarders::BaseForwarder)
    end
  end

  describe '.attrs' do
    it 'creates an Attributes forwarder' do
      expect(Dio.attribute(1)).to be_a(Dio::Forwarders::AttributeForwarder)
    end
  end

  describe '.string_hash' do
    it 'creates a String Hash forwarder' do
      expect(Dio.string_hash({ 'a' => 1 })).to be_a(
        Dio::Forwarders::StringHashForwarder
      )
    end
  end
end
