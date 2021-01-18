# Dio - Dive Into Objects!

Dio, or "Dive Into Objects", is a wrapper for Ruby objects that do not have a
Pattern Matching interface defined, but have methods which make them able to
implement an approximation of it:

```ruby
Dio[1] in { succ: { succ: { succ: 4 } } }
# => true
```

Using this interface we can even pattern match against arbitrary objects by
treating the pattern match keys as method calls to "dive into" an object to
match against it.

## Usage

There are three core types of Forwarders, the center of how Dio works:

1. **Dynamic** - Uses `public_send` for `Hash` matches, and `Array` method coercion for `Array` matches
2. **Attribute** - Uses `attr_*` methods as source of match data
3. **String Hash** - Treats `String` Hashes like `Symbol` ones for the purpose of matching.

Let's take a look at each of them.

### Dynamic Forwarder

Used with `Dio.dynamic` or `Dio[]`, the default forwarder. This uses `public_send` to extract attributes for pattern matching.

#### With Hash Matching

With an `Integer` this might look like this:

```ruby
Dio[1] in { succ: { succ: { succ: 4 } } }
# => true
```

This has the same result as calling `1.succ.succ.succ` with each nested `Hash` in the pattern match working on the next value. That means it can also be used to do this:

```ruby
Dio[1] in {
  succ: { chr: "\x02", to_s: '2' },
  to_s: '1'
}
```

#### With Array Matching

If the object under the wrapper provides a method that can be used to coerce the value into an `Array` it can be used for an `Array` match.

Those methods are: `to_a`, `to_ary`, and `map`.

Given a `Node` class with a value and a set of children:

```ruby
Node = Struct.new(:value, :children)
```

We can match against it as if it were capable of natively pattern matching:

```ruby
tree = Node[1,
  Node[2, Node[3, Node[4]]],
  Node[5],
  Node[6, Node[7], Node[8]]
]

case Dio.dynamic(tree)
in [1, [*, [5, _], *]]
  true
else
  false
end
```

### Attribute Forwarder

Attribute Forwarders are more conservative than Dynamic ones as they only work on public attributes, or those that are defined with `attr_*`. In the case of this class:

```ruby
class Person
  attr_reader :name, :age, :children

  def initialize(name:, age:, children: [])
    @name = name
    @age = age
    @children = children
  end
end
```

...the attributes available would be `name`, `age`, and `children`. This also means that you can dive into `children` as well.

#### With Hash Matching

Let's say we had Alice here:

```ruby
Person.new(
  name: 'Alice',
  age: 40,
  children: [
    Person.new(name: 'Jim', age: 10),
    Person.new(name: 'Jill', age: 10)
  ]
)
```

With Hash style matching we can do this:

```ruby
case Dio.attribute(alice)
in { name: /^A/, age: 30..50 }
  true
else
  false
end
```

...which, as pattern matches use `===` lets us use a lot of other fun things. We can even go deeper into searching through the `children` attribute:

```ruby
case Dio.attribute(alice)
in { children: [*, { name: /^J/ }, *] }
  true
else
  false
end
```

#### With Array Matching

This one is a bit more spurious, as it applies the attributes in the name it sees them. For something like our `Node` above with two attributes it will work the same as `dynamic`.

### String Hash Forwarder

Pattern Matching cannot apply to `String` keys, which can be annoying when working with data and not wanting to deep transform it into `Symbol` keys. The String Hash Forwarder tries to address this.

#### With Hash Matching

Let's say we had the following `Hash`:

```ruby
hash = {
  'a' => 1,
  'b' => 2,
  'c' => {
    'd' => 3,
    'e' => {
      'f' => 4
    }
  }
}
```

We can match against it by using the `Symbol` equivalents of our `String` keys:

```ruby
case Dio.string_hash(hash)
in { a: 1, b: 2 }
  true
else
  false
end
```

...and because of the nature of Dio you can continue to dive deeper:

```ruby
case Dio.string_hash(hash)
in { a: 1, b: 2, c: { d: 1..10, e: { f: 3.. } } }
  true
else
  false
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dio'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dio


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/baweaver/dio. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Dio project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/baweaver/dio/blob/master/CODE_OF_CONDUCT.md).
