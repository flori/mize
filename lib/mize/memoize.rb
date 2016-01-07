require 'mize/cache_methods'

module Mize
  module Memoize
    # Automatically memoize calls of the the methods +method_ids+. The
    # memoized results do NOT ONLY depend on the arguments, but ALSO on the
    # object the method is called on.
    def memoize_method(*method_ids)
      opts = method_ids.last.respond_to?(:to_hash) ? method_ids.pop.to_hash : {}

      include CacheMethods
      method_ids.each do |method_id|
        method_id = method_id.to_s.to_sym
        memoize_apply_visibility method_id do
          orig_method = instance_method(method_id)
          __send__(:define_method, method_id) do |*args|
            mc = __memoize_cache__
            if mc.key?(method_id) and result = mc[method_id][args]
              result
            else
              (mc[method_id] ||= {})[args] = result = orig_method.bind(self).call(*args)
              $DEBUG and warn "#{self.class} cached method #{method_id}(#{args.inspect unless args.empty?}) = #{result.inspect} [#{__id__}]"
              opts[:freeze] and result.freeze
            end
            result
          end
        end
      end
      method_ids.size == 1 ? method_ids.first : method_ids
    end

    include CacheMethods

    # Automatically memoize calls of the functions +function_ids+. The
    # memoized result does ONLY depend on the arguments given to the
    # function.
    def memoize_function(*function_ids)
      opts = function_ids.last.respond_to?(:to_hash) ? method_ids.pop.to_hash : {}

      mc = __memoize_cache__
      function_ids.each do |function_id|
        function_id = function_id.to_s.to_sym
        memoize_apply_visibility function_id do
          orig_function = instance_method(function_id)
          __send__(:define_method, function_id) do |*args|
            if mc.key?(function_id) and result = mc[function_id][args]
              result
            else
              (mc[function_id] ||= {})[args] = result = orig_function.bind(self).call(*args)
              opts[:freeze] and result.freeze
              $DEBUG and warn "#{self.class} cached function #{function_id}(#{args.inspect unless args.empty?}) = #{result.inspect}"
            end
            result
          end
        end
      end
      function_ids.size == 1 ? function_ids.first : function_ids
    end
  end
end
