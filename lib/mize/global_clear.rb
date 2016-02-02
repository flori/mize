require 'monitor'

module Mize
  class << self

    # Clear all memoization caches at once.
    def cache_clear
      each_cache do |id, cache|
        cache and cache.clear
        cache_tracker.delete id
      end
    end

    private

    def each_cache
      cache_tracker.synchronize do
        cache_tracker.each_name do |id|
          begin
            cache = ObjectSpace._id2ref id
          rescue RangeError
          end
          cache.conform_to?(Mize::CacheProtocol) or cache = nil
          yield id, cache
        end
      end
    end

    def cache_tracker
      @cache_tracker ||= Mize.default_cache.dup
    end

    def track_cache(cache_id)
      cache_tracker.exist?(cache_id) and return
      cache_tracker.synchronize do
        cache_tracker.write cache_id, true
      end
    end
  end

  cache_tracker
end
