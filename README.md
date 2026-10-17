# Mize

Lightweight memoization for Ruby. Annotate any method or function with a
single `memoize` call and Mize handles result caching, invalidation, and
Rails-aware reload for you.

Works with Ruby 3.1 – 4.0 (tested via `.all_images.yml`).

## Installation

```sh
gem install mize
```

or add to your `Gemfile`:

```ruby
gem 'mize'
```

## Usage

### Memoize a method

Results are cached **per receiver**. Two different objects get independent
caches even for identical arguments:

```ruby
class A
  @@c = 0

  memoize method:
  def foo(x)
    "foo #{x} #{@@c += 1}"
  end
end

a1 = A.new
a1.foo(23) # => "foo 23 1"
a1.foo(23) # => "foo 23 1"   (cached)

a2 = A.new
a2.foo(23) # => "foo 23 2"   (different receiver)
a2.foo(23) # => "foo 23 2"   (cached)
```

### Memoize a function

Results are cached **globally** — the receiver is ignored. All instances
share one cache entry per argument set:

```ruby
class B
  @@c = 0

  memoize function:
  def foo(x)
    "foo #{x} #{@@c += 1}"
  end
end

b1 = B.new
b1.foo(23) # => "foo 23 1"
b2 = B.new
b2.foo(23) # => "foo 23 1"   (same cache as b1)
```

### Options

| Option       | Default | Effect                                |
|:-------------|:--------|:--------------------------------------|
| `freeze:`    | `false` | Freeze the cached result if possible  |
| `store_nil:` | `true`  | Cache `nil` results; `false` recomputes |

```ruby
memoize method:, freeze: true, store_nil: false
def expensive_query
  # ...
end
```

Keyword arguments are supported and included in the cache key:

```ruby
memoize method:
def lookup(name, limit: 10)
  # ...
end

lookup("flori")           # => computes
lookup("flori")           # => cached
lookup("flori", limit: 5) # => separate cache entry
```

### Clearing the cache

Clear a single method's cache entries by name:

```ruby
a1.mize_cache_clear_name(:foo)
```

Clear **all** cached entries for a receiver (method memoization) or for the
class (function memoization):

```ruby
a1.mize_cache_clear          # method: only a1's cache
B.mize_cache_clear           # function: global shared cache
```

## Global cache clearing

`Mize.cache_clear` walks the entire object space for anything including
`Mize::CacheProtocol` and clears it. Use this in test setups or teardown:

```ruby
Mize.cache_clear
```

## Rails integration

When Rails is loaded, Mize registers a railtie that calls
`Mize.cache_clear` on every `to_prepare` block (i.e. on each code reload in
development). If your model or class defines a `#reload` method, Mize
prepends its own `reload` that delegates to `super` and then clears
memoized entries automatically.

## Custom cache backend

The default backend is an in-memory `Hash` guarded by a `MonitorMixin`.
Swap in your own (e.g. Redis, Memcached) by implementing the
`Mize::CacheProtocol` interface:

```ruby
class RedisCache
  include Mize::CacheProtocol

  def initialize
    @r = Redis.new
  end

  def read(name, options = nil)
    @r.get("mize:#{name}")
  end

  def write(name, value, options = nil)
    @r.set("mize:#{name}", Marshal.dump(value))
  end

  def exist?(name, options = nil)
    !@r.get("mize:#{name}").nil?
  end

  def delete(name, options = nil)
    @r.del("mize:#{name}")
  end

  def clear(options = nil)
    # delete matching keys or flushdb
  end

  def each_name(&block)
    # yield each key
    self
  end

  def prototype
    dup
  end
end

Mize.configure do
  cache RedisCache.new
end
```

Any object that `include Mize::CacheProtocol` and implements `read`,
`write`, `exist?`, `delete`, `clear`, `each_name`, and `prototype` will
work.

## Documentation

Complete API documentation is available at: [GitHub.io](https://flori.github.io/mize/)

## Repository

* https://github.com/flori/mize

## Author

[Florian Frank](mailto:flori@ping.de)

## License

MIT
