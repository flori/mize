require 'thread'

# Mize — a minimal, dependency-free memoization toolkit for Ruby.
#
# Mize lets you wrap any method (or a bare, stateless "function") so that its
# result is cached and reused for identical arguments. It ships with an
# in-memory +Mize::DefaultCache+ but accepts any object that includes
# +Mize::CacheProtocol+, so you can plug in Redis, Memcached, and friends.
#
# @example Wrapping a method
#   class Greeter
#     include Mize::Memoize
#
#     def expensive(name)
#       # ...
#     end
#     memoize method: :expensive
#   end
module Mize
  # Process-wide lock guarding all cache and wrapping mutations.
  #
  # Every operation that mutates shared Mize state (+memoize+,
  # +Mize.cache_clear+, +Mize::Reload#reload+) serialises on this mutex, so
  # the toolkit is safe to use from multiple threads.
  MUTEX = Mutex.new

  class << self
    # Bookkeeping of already-wrapped targets.
    #
    # Maps +[module, method_id, function]+ => +[freeze, store_nil]+ so that
    # duplicate +memoize+ calls can be detected and conflicting options
    # rejected. Cleared on +Mize::Reload#reload+.
    attr_accessor :wrapped
  end
  self.wrapped = {}
end

require 'mize/version'
require 'mize/memoize'
require 'mize/configure'
require 'mize/global_clear'
require 'mize/railtie' if defined? Rails

# Inject +memoize+ into every module so any class can opt in with a single
# +include Mize::Memoize+.
class ::Module
  prepend Mize::Memoize
end
