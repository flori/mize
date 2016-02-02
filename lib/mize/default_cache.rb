require 'monitor'

class Mize::DefaultCache < Hash
  include MonitorMixin

  private(*(instance_methods - Object.instance_methods - %i[ synchronize ]))

  def clear(options = nil)
    super()
  end

  def exist?(name, options = nil)
    key?(name)
  end

  def read(name, options = nil)
    fetch(name, nil)
  end

  def write(name, value, options = nil)
    store(name, value)
  end

  def delete(name, options = nil)
    super(name)
  end

  def each_name(&block)
    each_key(&block)
  end

  alias prototype dup

#  conform_to Mize::CacheProtocol
end
