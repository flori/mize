# Reload/invalidation hook, prepended into any module that memoizes an
# instance method.
#
# When a class defines (or inherits) its own +reload+, Mize wraps it so the
# cache is guaranteed to be cleared alongside whatever the user's +reload+
# does, keeping memoized state consistent after a full object reload.
module Mize::Reload
  # Run the parent +reload+ (if any), then clear Mize's bookkeeping and the
  # object's memoization cache.
  #
  # The whole sequence is serialized on +Mize.synchronize+. +Mize.wrapped+ is
  # reset so a re-memoization with different options is allowed, and
  # +mize_cache_clear+ drops every cached value for this object.
  #
  # @return [Object] The result of the parent +reload+ if one was defined,
  #   otherwise +self+.
  def reload(*)
    Mize.synchronize do
      result = self
      if defined? super
        result = super
      end
      Mize.wrapped.clear
      mize_cache_clear
      result
    end
  end
end
