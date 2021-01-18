require "bundler/setup"
require "dio"

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

class Person
  attr_reader :name, :age, :children

  def initialize(name:, age:, children: [])
    @name = name
    @age  = age
    @children = children
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
