module Mize
  # Rails integration.
  #
  # Hooks into the Rails preparation lifecycle so that every code reload
  # clears all Mize caches via +Mize.cache_clear+, preventing stale memoized
  # results from surviving a development-environment class reload.
  #
  # Loaded automatically by +mize.rb+ only when +Rails+ is defined.
  class Railtie < Rails::Railtie
    config.to_prepare do
      Mize.cache_clear
    end
  end
end
