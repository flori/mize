# The default in-memory cache backend.
#
# A plain +Hash+ wrapper that implements just enough of the Mize cache
# protocol to back memoization out of the box: +read+ / +write+ /
# +exist?+ / +delete+ / +clear+ / +each_name+.
#
# Individual operations are atomic under the GVL. For multi-step
# atomicity (e.g. check→compute→write), wrap the call in
# +Mize.synchronize+.
#
# Because it is backed by a plain +Hash+, entries are never evicted until you
# clear the cache explicitly (or the object is garbage-collected). For
# persistent or evicting behaviour, swap in a different
# +Mize::CacheProtocol+ implementation via +Mize.configure+.
class Mize::DefaultCache
  include Mize::CacheProtocol

  # Create an empty cache.
  #
  # @return [Mize::DefaultCache] A new, empty cache instance.
  def initialize
    @data = {}
  end

  # Clear the cache by removing all entries from the cache.
  #
  # @return [self] The receiver, for chaining.
  def clear(options = nil)
    @data.clear
    self
  end

  # Determine whether a cache entry exists in this cache.
  #
  # @param name [String] The name of the cache entry to check.
  # @param options [Hash, nil] Optional backend-specific options (ignored).
  # @return [Boolean] Whether or not the cache entry exists.
  def exist?(name, options = nil)
    @data.key?(name)
  end

  # Read a value from the cache by name. If the entry does not exist in the
  # cache, it will return +nil+.
  #
  # @param name [String] The name of the cache entry to read.
  # @param options [Hash, nil] Optional backend-specific options (ignored).
  # @return [Object, nil] The value stored in the cache for +name+, or +nil+.
  def read(name, options = nil)
    @data.fetch(name, nil)
  end

  # Write a value to the cache by name. If an entry with the same name already
  # exists in the cache, it will be overwritten.
  #
  # @param name [String] The name of the cache entry to write.
  # @param value [Object] The value to store in the cache for +name+.
  # @param options [Hash, nil] Optional backend-specific options (ignored).
  # @return [Object] The value now stored in the cache.
  def write(name, value, options = nil)
    @data.store(name, value)
  end

  # Delete a cache entry by name. If an entry does not exist in the cache, it
  # will do nothing.
  #
  # @param name [String] The name of the cache entry to delete.
  # @param options [Hash, nil] Optional backend-specific options (ignored).
  # @return [Object, nil] The value stored in the cache before deletion, or
  #   +nil+ if the entry was absent.
  def delete(name, options = nil)
    @data.delete(name)
  end

  # Each name of the cache is yielded to the block.
  #
  # @yieldparam name [String] Each cache entry name, in turn.
  # @return [self] The receiver, for chaining.
  def each_name(&block)
    @data.each_key(&block)
    self
  end

  # Initialize a duplicate of this cache.
  #
  # The underlying store is shallow-copied so the original and the duplicate
  # diverge immediately (this is what +prototype+ relies on to hand each
  # memoized object its own independent cache).
  #
  # @param other [Mize::DefaultCache] The cache to initialize a duplicate of.
  # @return [Mize::DefaultCache] +self+, now a copy of +other+.
  def initialize_dup(other)
    super
    other.instance_variable_set :@data, @data.dup
  end

  # Create a shallow copy of this cache; the public name for +dup+.
  #
  # @return [Mize::DefaultCache] A new cache with an independent copy of the
  #   entries.
  alias prototype dup
end
