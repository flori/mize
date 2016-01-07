require 'mize/cache_protocol'
require 'mize/default_cache'

module Mize::CacheMethods
  # Clear cached values for all methods/functions of this object.
  def mize_cache_clear
    __mize_cache__.clear
    self
  end

  private

  # Set the cache object to +cache+.
  def __mize_cache__=(cache)
    Mize::CacheProtocol.check cache
    @__mize_cache__ = cache
  end

  # Return the cache object.
  def __mize_cache__
    if @__mize_cache__
      @__mize_cache__
    else
      self.__mize_cache__ = Mize.default_cache.prototype
    end
  end

  # Build a key prefix for +name+.
  def build_key_prefix(name)
    "mize/#{name}"
  end

  # Build a +name+ prefixed key for the arguments +args+.
  def build_key(name, *args)
    "#{build_key_prefix(name)}/#{Marshal.dump(args)}"
  end

  # Apply the visibility of method +id+ to the wrapper method of this method.
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
