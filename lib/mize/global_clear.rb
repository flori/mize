module Mize
  class << self

    # Clear all memoization caches at once.
    #
    # Walks every live +Mize::CacheProtocol+ instance in the process (see
    # +each_cache+) and invokes +clear+ on each, inside +Mize::MUTEX+ so the
    # sweep is atomic with respect to concurrent reads/writes.
    #
    # @return [Mize] The +Mize+ module itself.
    def cache_clear
      each_cache(&:clear)
    end

    private

    # Yield every live +Mize::CacheProtocol+ object to the block.
    #
    # The sweep runs under +Mize::MUTEX+ so it cannot observe a half-cleared
    # cache. Objects only appear here because they
    # +include Mize::CacheProtocol+.
    #
    # @yield [cache] Yields each live cache backend in turn.
    # @return [Mize] The +Mize+ module itself.
    def each_cache
      Mize::MUTEX.synchronize do
        for cache in ObjectSpace.each_object(Mize::CacheProtocol)
          yield cache
        end
      end
      self
    end
  end
end
