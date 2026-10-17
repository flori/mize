# Configuration helpers mixed in / extended onto the top-level +Mize+ object.
#
# Provides the block-based +Mize.configure+ DSL and the +default_cache+
# accessor so users can swap the global cache backend.
module Mize::Configure
  # The global default cache backend.
  #
  # Every memoized object that has not been given an explicit cache
  # instantiates a fresh copy (via +prototype+ / "dup") of this backend.
  # Reassign it to route all new memoized calls through a different store
  # (Redis, Memcached, ...).
  #
  # @return [Mize::CacheProtocol] The current global default cache backend.
  attr_accessor :default_cache

  # Set the default cache object to +cache+.
  #
  # Intended for use inside a +Mize.configure {}+ block.
  #
  # @param cache [Mize::CacheProtocol] The backend to install as the default.
  # @return [Mize::CacheProtocol] The backend now installed.
  def cache(cache)
    self.default_cache = cache
  end

  # Configure Mize by evaluating +block+ in the context of the +Mize+ object.
  #
  # Inside the block, +cache+ (and the +default_cache+ accessor) are called
  # directly on +Mize+, so no receiver is required.
  #
  # @example
  #   Mize.configure do
  #     cache MyRedisCache.new
  #   end
  #
  # @yield The configuration block, evaluated via +instance_eval+.
  # @return [Object] The return value of +block+.
  def configure(&block)
    instance_eval(&block)
  end
end

module Mize
  extend Mize::Configure
end

# Install the built-in in-memory backend as the global default.
Mize.default_cache = Mize::DefaultCache.new
