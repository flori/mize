require 'mize/cache_methods'
require 'mize/reload'

module Mize
  # Memoization entry point, prepended into every +::Module+ by +mize.rb+.
  #
  # Including this module (or relying on the global +prepend+) exposes
  # +memoize+, +mize_cache_clear+ and +mize_cache_clear_name+ on the
  # receiver. The heavy lifting is delegated to +Mize::CacheMethods+ for
  # key/state management and +Mize::Reload+ for cache invalidation.
  module Memoize
    include CacheMethods

    # Memoize either a +method+ or a +function+.
    #
    # In the +method+ case the memoized results do NOT ONLY depend on the
    # arguments, but ALSO on the object the method is called on (each object
    # keeps its own cache). In the +function+ case the memoized results ONLY
    # depend on the arguments, and a single shared cache backs every call.
    #
    # You must specify exactly one of +method:+ or +function:+; passing both
    # or neither raises +ArgumentError+.
    #
    # @param method [String, Symbol, nil] The instance method to wrap.
    # @param function [String, Symbol, nil] The bare/stateless function to wrap.
    # @param freeze [true, false] When true, successfully computed results are
    #   frozen (if they respond to +freeze+) to make them immutable.
    # @param store_nil [true, false] When false, +nil+ results are not stored
    #   and are recomputed every call; defaults to +true+ (store +nil+).
    # @raise [ArgumentError] If both or neither of +method:+/+function:+ are
    #   given.
    # @return [Symbol] The (stringified) symbol of the wrapped method id.
    # @example Memoizing an instance method
    #   class Foo
    #     include Mize::Memoize
    #
    #     def expensive(x) x * 2 end
    #     memoize method: :expensive, freeze: true
    #   end
    def memoize(method: nil, function: nil, freeze: false, store_nil: true)
      Mize.synchronize do
        if method && function
          raise ArgumentError, 'memoize a method xor a function'
        elsif method
          wrap_method method, freeze: freeze, store_nil: store_nil
        elsif function
          wrap_method function, function: true, freeze: freeze, store_nil: store_nil
        else
          raise ArgumentError, 'missing keyword: method/function'
        end
      end
    end

    private

    class << self
      private

      # Compute the real result of a memoized call.
      #
      # Binds +orig_method+ to +context+ and invokes it with +args+; when
      # running under +$DEBUG+ a diagnostic line is emitted to +STDERR+.
      #
      # @param method_id [Symbol] The wrapped method name (diagnostics only).
      # @param orig_method [UnboundMethod] The original, unwrapped method.
      # @param key [String] The cache key for this call (diagnostics only).
      # @param context [Object] The object the method is bound to.
      # @param args [Array] The positional arguments.
      # @param kargs [Hash] The keyword arguments.
      # @param freeze [true, false] Whether to freeze the resulting value.
      # @return [Object] The (possibly frozen) computed result.
      def compute_result(method_id, orig_method, key, context, args, kargs, freeze)
        result = orig_method.bind(context).call(*args)
        if $DEBUG
          warn "#{context.class} cached method "\
            "#{method_id}(#{[ args, kargs ].inspect unless args.size + kargs.size == 0}) = "\
            "#{result.inspect} [#{__id__}]"
        end
        freeze and result.freeze rescue nil
        result
      end
    end

      # Wrap +method_id+ with a memoizing closure.
      #
      # Idempotency: a +[self, method_id, function]+ target already present in
      # +Mize.wrapped+ with identical +freeze+ / +store_nil+ options is a
      # no-op; conflicting options raise +ArgumentError+.
      #
      # For instance methods (+function: false+) the receiver gets its own
      # per-object cache via +Mize::CacheMethods+ and +Mize::Reload+ is
      # prepended so +reload+ invalidates entries. For bare functions a single
      # shared cache is used instead.
      #
      # @param method_id [String, Symbol] The name of the method to wrap.
      # @param freeze [true, false] Forwarded to the wrapper's result handling.
      # @param function [true, false] Whether +method_id+ is a bare function.
      # @param store_nil [true, false] Whether +nil+ results should be cached.
      # @raise [ArgumentError] If the target is already wrapped with different
      #   +freeze+ / +store_nil+ options.
      # @return [Symbol] The stringified symbol of the wrapped method id.
      def wrap_method(method_id, freeze: false, function: false, store_nil: true)
      verbose, $VERBOSE = $VERBOSE, nil
      if already_wrapped = Mize.wrapped[ [ self, method_id, function ] ]
        if already_wrapped == [ freeze, store_nil ]
          return method_id
        else
          raise ArgumentError,
            "encountered mismatching memoize declaration within #{self} for freeze, store_nil:"\
            " #{already_wrapped} != #{ [ freeze, store_nil ] }"
        end
      end
      include CacheMethods

      function and mc = __mize_cache__

      unless function
        prepend Mize::Reload
      end

      method_id = method_id.to_s.to_sym
      memoize_apply_visibility method_id do
        orig_method = instance_method(method_id)
        __send__(:define_method, method_id) do |*args, **kargs|
          function or mc = __mize_cache__
          key = build_key(method_id, *args, **kargs)
          if mc.exist?(key)
            mc.read(key)
          else
            result = Mize::Memoize.send(
              :compute_result, method_id, orig_method, key, self, args, kargs, freeze
            )
            if store_nil || !result.nil?
              mc.write(key, result)
            end
            result
          end
        end
      end
      Mize.wrapped[ [ self, method_id, function ] ] = [ freeze, store_nil ]
      method_id
    ensure
      $VERBOSE = verbose
    end
  end
end
