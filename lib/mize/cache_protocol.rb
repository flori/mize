# Marker interface for Mize-compatible cache backends.
#
# A cache backend "is a" +Mize::CacheProtocol+ simply by including this
# module. No methods are mandated — the module exists solely as a type tag
# that Mize can match against.
#
# The primary consumer is +Mize.cache_clear+ (see +Mize::GlobalClear+), which
# walks the heap with +ObjectSpace.each_object(Mize::CacheProtocol)+ to locate
# every live cache instance and clear it. This is what turns a per-object
# cache into a globally clearable one without an explicit registry.
#
# @example A minimal compliant backend
#   class MyCache
#     include Mize::CacheProtocol
#
#     def read(name, options = nil) ... end
#     def write(name, value, options = nil) ... end
#     def clear(options = nil) ... end
#   end
module Mize::CacheProtocol
end
