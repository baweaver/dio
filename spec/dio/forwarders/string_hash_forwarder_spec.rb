require 'spec_helper'

RSpec.describe Dio::Forwarders::StringHashForwarder do
  let(:hash) do
    {
      'a' => 1,
      'b' => 2,
      'c' => {
        'd' => 3,
        'e' => {
          'f' => 4
        }
      }
    }
  end

  describe '#deconstruct_keys' do
    context 'Basic Hash dives' do
      it 'can dive into a String Hash' do
        value =
          case Dio.string_hash(hash)
          in { a: 1, b: 2 }
            true
          else
            false
          end

        expect(value).to eq(true)
      end
    end

    context 'Nested object dives' do
      it 'can dive into deep hashes' do
        value =
          case Dio.string_hash(hash)
          in { a: 1, b: 2, c: { d: 1..10, e: { f: 3.. } } }
            true
          else
            false
          end

        expect(value).to eq(true)
      end
    end
  end
end
