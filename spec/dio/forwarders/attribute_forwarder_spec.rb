require 'spec_helper'

RSpec.describe Dio::Forwarders::AttributeForwarder do
  let(:tree) do
    Node[1,
      Node[2, Node[3, Node[4]]],
      Node[5],
      Node[6, Node[7], Node[8]]
    ]
  end

  let(:alice) do
    Person.new(
      name: 'Alice',
      age: 40,
      children: [
        Person.new(name: 'Jim', age: 10),
        Person.new(name: 'Jill', age: 10)
      ]
    )
  end

  describe '#deconstruct_keys' do
    context 'Basic object dives' do
      it 'can dive into a Person' do
        value =
          case Dio.attribute(alice)
          in { name: /^A/, age: 30..50 }
            true
          else
            false
          end

        expect(value).to eq(true)
      end
    end

    context 'Nested object dives' do
      it 'can dive into people for relatives' do
        value =
          case Dio.attribute(alice)
          in { children: [*, { name: /^J/ }, *] }
            true
          else
            false
          end

        expect(value).to eq(true)
      end
    end

    context 'Unknown keys' do
      it 'will raise an error on non-attribute keys' do
        expect {
          case Dio.attribute(alice)
          in { a:, b:, c: }
            true
          else
            false
          end
        }.to raise_error(
          Dio::Errors::UnknownAttributesProvided,
          'Unknown attribute arguments provided to method: a, b, c'
        )
      end
    end
  end

  describe '#deconstruct' do
    it 'can dive through an array-like object' do
      value =
        case Dio.attribute(tree)
        in [1, [*, [5, _], *]]
          true
        else
          false
        end

      expect(value).to eq(true)
    end
  end
end
