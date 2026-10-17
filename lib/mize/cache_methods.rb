require 'mize/cache_protocol'
require 'mize/default_cache'

# Per-object memoization bookkeeping.
#
# Mixed into any module that calls +memoize+. Each *object* gets its own
# lazily-created cache instance (a copy of +Mize.default_cache+), and the
# key-building helpers below produce stable, argument-sensitive cache keys.
#
# State is deliberately kept per-object: two instances of the same memoized
# class do not share a cache, which is the expected semantics for instance
# methods.
module Mize::CacheMethods
  # Clear cached values for all methods/functions of this object.
  #
  # @return [self] The receiver, for chaining.
  def mize_cache_clear
    __mize_cache__.clear
    self
  end

  # Clear all cached results for the method/function +name+.
  #
  # @param name [String, Symbol] The name of the memoized method/function.
  # @return [self] The receiver, for chaining.
  def mize_cache_clear_name(name)
    name = build_key_prefix(name)
    __mize_cache__.each_name do |n|
      n =~ %r{\A#{Regexp.quote(name)}/} and __mize_cache__.delete(n)
    end
    self
  end

  private

  # Set the cache object to +cache+.
  #
  # @param cache [Mize::CacheProtocol] The cache backend to store in.
  # @return [Mize::CacheProtocol] The cache backend now stored in +self+.
  def __mize_cache__=(cache)
    @__mize_cache__ = cache
  end

  # Return the cache object, creating one on first use.
  #
  # The first access makes a fresh copy of +Mize.default_cache+ (via
  # +prototype+ / "dup") so that each object holds an independent store.
  #
  # @return [Mize::CacheProtocol] This object's cache backend.
  def __mize_cache__
    if defined?(@__mize_cache__)
      @__mize_cache__
    else
      self.__mize_cache__ = Mize.default_cache.prototype
    end
  end

  # Build a key prefix for +name+.
  #
  # @param name [String, Symbol] The method/function name.
  # @return [String] The namespaced prefix, e.g. +"mize/foo"+.
  def build_key_prefix(name)
    "mize/#{name}"
  end

  # Build a +name+ prefixed key for the arguments +args+.
  #
  # The argument list is +Marshal#+d so structurally-identical arguments
  # always collide on the same key regardless of object identity.
  #
  # @param name [String, Symbol] The method/function name.
  # @param args [Array] The arguments to key on (positional, then splatted
  #   keywords).
  # @return [String] The full cache key.
  def build_key(name, *args)
    "#{build_key_prefix(name)}/#{Marshal.dump(args)}"
  end

  # Apply the visibility of method +id+ to the wrapper method of this method.
  #
  # The block is expected to (re)define +id+ as +public+; afterwards the
  # original visibility is re-applied in the +ensure+ clause so a memoized
  # +private+ method stays +private+.
  #
  # @param id [String, Symbol] The name of the method whose visibility to
  #   mirror.
  # @yield The block that performs the +define_method+ of +id+.
  def memoize_apply_visibility(id)
    visibility = instance_eval do
      case
      when private_method_defined?(id)
        :private
      when protected_method_defined?(id)
        :protected
      end
    end
    yield
  ensure
    visibility and __send__(visibility, id)
  end
end
