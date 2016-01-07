require 'mize/cache_methods'
require 'mize/reload'

module Mize
  module Memoize
    include CacheMethods

    # Memoize either a +method+ or a +function+. In the former case the
    # memoized results do NOT ONLY depend on the arguments, but ALSO on the
    # object the method is called on. In the latter the memoized results ONLY
    # depend on the arguments given to the function. If the +freeze+ argument
    # is true, the result is frozen if possible to make it immutable.
    def memoize(method: nil, function: nil, freeze: false)
      if method && function
        raise ArgumentError, 'memoize a method xor a function'
      elsif method
        wrap_method method, freeze: freeze
      elsif function
        wrap_method function, function: true, freeze: freeze
      else
        raise ArgumentError, 'missing keyword: method/function'
      end
    end

    private

    def wrap_method(method_id, freeze: false, function: false)
      include CacheMethods

      mc = __mize_cache__

      unless function
        prepend Mize::Reload
      end

      method_id = method_id.to_s.to_sym
      memoize_apply_visibility method_id do
        orig_method = instance_method(method_id)
        __send__(:define_method, method_id) do |*args|
          function or mc = __mize_cache__
          Mize.__send__ :track_cache, mc.__id__
          key = build_key(method_id, *args)
          if mc.exist?(key) and result = mc.read(key)
            result
          else
            result = orig_method.bind(self).call(*args)
            mc.write(key, result)
            if $DEBUG
              warn "#{self.class} cached method "\
                "#{method_id}(#{args.inspect unless args.empty?}) = "\
                "#{result.inspect} [#{__id__}]"
            end
            freeze and result.freeze rescue result
          end
          result
        end
      end
      method_id
    end
  end
end
