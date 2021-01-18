require 'spec_helper'

RSpec.describe Dio::Forwarders::BaseForwarder do
  let(:tree) do
    Node[1,
      Node[2, Node[3, Node[4]]],
      Node[5],
      Node[6, Node[7], Node[8]]
    ]
  end

  describe '#deconstruct_keys' do
    describe 'Basic object dives' do
      it 'can dive into an Integer' do
        value =
          case Dio.dynamic(1)
          in { succ: { succ: { succ: 4 } } }
            true
          else
            false
          end

        expect(value).to eq(true)
      end
    end

    describe 'Nested object dives' do
      it 'can dive into nodes' do
        value =
          case Dio.dynamic(tree)
          in { value: 1 }
            true
          else
            false
          end

        expect(value).to eq(true)
      end

      it 'can dive into nodes' do
        value =
          case Dio.dynamic(tree)
          in {
            value:, children: [*, { value: 5 } ,*]
          }
            true
          else
            false
          end

        expect(value).to eq(true)
      end
    end
  end

  describe '#deconstruct' do
    it 'can dive through an array-like object' do
      value =
        case Dio.dynamic(tree)
        in [1, [*, [5, _], *]]
          true
        else
          false
        end

      expect(value).to eq(true)
    end

    it 'cannot dive through a non-array like object' do
      expect {
        case Dio.dynamic(1)
        in [1, [*, [5, _], *]]
          true
        else
          false
        end
      }.to raise_error(Dio::Errors::NoDeconstructionMethod)
    end
  end
end
