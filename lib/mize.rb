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

    # Acquire the global Mize mutex for the duration of +block+.
    #
    # Exposes the internal +MUTEX+ under a stable API so callers can make
    # a sequence of memoized calls atomic with respect to other threads:
    #
    # @example
    #   Mize.synchronize do
    #     obj.foo(42)
    #     obj.bar(42)
    #   end
    #
    # The hot path (individual memoized calls) is lock-free by design; use
    # this when you need the check→compute→write cycle to be indivisible.
    #
    # MRI forbids +Mutex#synchronize+ from a trap context (signal handlers
    # and GC finalizers), raising +ThreadError: can't be called from trap
    # context+. This is an intentional, still-current design decision (see
    # DevMeeting-2025-07-10 on
    # https://bugs.ruby-lang.org/issues/19473), not a bug being patched, so
    # this method rescues that specific error and runs +block+ without the
    # lock rather than raising into a finalizer. Other +ThreadError+s (e.g.
    # recursive locking) are re-raised.
    #
    # @yield Executes the block while holding the mutex.
    # @return [Object] The return value of +block+.
    def synchronize(&block)
      MUTEX.synchronize(&block)
    rescue ThreadError => e
      if e.message.include?("trap context")
        block.()
      else
        raise e
      end
    end
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
