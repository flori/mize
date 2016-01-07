require 'protocol'

# The protocol the cache object has to conform to. This is a minimal subset of
# the ActiveSupport::Cache::Store protocol.
Mize::CacheProtocol = Protocol do
  # Clear the entire cache.
  def clear(options = nil)
  end

  # Returns true if the cache contains an entry for the given key.
  def exist?(name, options = nil)
  end

  # Fetches data from the cache, using the given key. If there is data in the
  # cache with the given key, then that data is returned. Otherwise, nil is
  # returned.
  def read(name, options = nil)
  end

  # Writes the value to the cache, with the key.
  def write(name, value, options = nil)
  end

  # Iterate over all cache entries and yield to their names.
  def each_name(&block)
  end

  # Return another cache instance that was correctly configured.
  def prototype
    dup
  end
end
