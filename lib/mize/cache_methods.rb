module Mize::CacheMethods
  # Clear cached values for all methods/functions.
  def memoize_cache_clear
    __memoize_cache__.clear
    self
  end

  private

  # Return the cache object.
  def __memoize_cache__
    @__memoize_cache__ ||= {}
  end

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
