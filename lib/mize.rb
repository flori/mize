module Mize
end

require 'mize/version'
require 'mize/memoize'
require 'mize/configure'
require 'mize/global_clear'
require 'mize/railtie' if defined? Rails

class ::Module
  prepend Mize::Memoize
end
