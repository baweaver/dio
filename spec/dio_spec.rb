class Node
  attr_reader :value, :children

  def initialize(value, *children)
    @value    = value
    @children = children
  end

  def to_a() = [@value, @children]

  def to_s
    return "(#{value})" if @children.empty?

    "(#{@value}, #{ @children.map(&:to_s).join(', ')})"
  end

  def self.[](...) = new(...)
end

RSpec.describe Dio do
  it "has a version number" do
    expect(Dio::VERSION).not_to be nil
  end

  describe 'PublicApi' do
    describe '.[]' do
      it 'creates a new DiveForwarder' do
        expect(Dio[1]).to be_a(Dio::DiveForwarder)
      end
    end
  end

  describe 'Functionality' do
    let(:tree) do
      Node[1,
        Node[2,
          Node[3,
            Node[4]
          ]
        ],
        Node[5],
        Node[6,
          Node[7],
          Node[8]
        ]
      ]
    end

    context 'Hash diving' do
      describe 'Basic object dives' do
        it 'can dive into an Integer' do
          value =
            case Dio[1]
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
            case Dio[tree]
            in { value: 1 }
              true
            else
              false
            end

          expect(value).to eq(true)
        end

        it 'can dive into nodes' do
          value =
            case Dio[tree]
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

    context 'Array diving' do
      it 'can dive through an array-like object' do
        value =
          case Dio[tree]
          in [1, [*, [5, _], *]]
            true
          else
            false
          end

        expect(value).to eq(true)
      end

      it 'cannot dive through a non-array like object' do
        expect {
          case Dio[1]
          in [1, [*, [5, _], *]]
            true
          else
            false
          end
        }.to raise_error(Dio::Errors::NoDeconstructionMethod)
      end
    end
  end
end
