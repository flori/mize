module Mize
end

require 'mize/version'
require 'mize/memoize'

class ::Module
  include Mize::Memoize
end
