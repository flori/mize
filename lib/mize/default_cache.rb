require 'monitor'

class Mize::DefaultCache
  include MonitorMixin

  def initialize
    @data = {}
  end

  def clear(options = nil)
    @data.clear
    self
  end

  def exist?(name, options = nil)
    @data.key?(name)
  end

  def read(name, options = nil)
    @data.fetch(name, nil)
  end

  def write(name, value, options = nil)
    @data.store(name, value)
  end

  def delete(name, options = nil)
    @data.delete(name)
  end

  def each_name(&block)
    @data.each_key(&block)
    self
  end

  def initialize_dup(other)
    super
    other.instance_variable_set :@data, @data.dup
  end

  alias prototype dup

  conform_to Mize::CacheProtocol
end
