require 'spec_helper'

class FooBar
  def self.reset
    @@foo = nil
    @@bar = nil
    @@baz = nil
    mize_cache_clear
  end

  def foo(*a)
    @@foo ||= 0
    @@foo += 1
  end
  memoize method: :foo

  def footsie(*a)
    @@footsie ||= 0
    @@footsie += 1
  end
  protected :footsie
  memoize method: :footsie

  def bar(*a)
    @@bar ||= 0
    @@bar += 1
  end
  memoize function: :bar

  private

  def baz(*a)
    @@baz ||= 0
    @@baz += 1
  end
  memoize function: :baz
end

describe Mize do
  before do
    FooBar.reset
    class ::Mize::DefaultCache
      public :empty?
    end
  end

  let(:fb1) { FooBar.new }

  let(:fb2) { FooBar.new }

  context 'memoize method' do
    it 'can cache methods' do
      expect(fb1.__send__(:__mize_cache__)).to be_empty
      expect(fb2.__send__(:__mize_cache__)).to be_empty
      expect(fb1.foo(1, 2)).to eq 1
      expect(fb2.foo(1, 2)).to eq 2
      expect(fb1.foo(1, 2, 3)).to eq 3
      expect(fb2.foo(1, 2, 3)).to eq 4
      expect(fb1.foo(1, 2)).to eq 1
      expect(fb2.foo(1, 2)).to eq 2
      fb1.mize_cache_clear
      fb2.mize_cache_clear
      expect(fb1.__send__(:__mize_cache__)).to be_empty
      expect(fb2.__send__(:__mize_cache__)).to be_empty
      expect(fb1.foo(1, 2)).to eq 5
      expect(fb2.foo(1, 2)).to eq 6
      expect(fb1.foo(1, 2)).to eq 5
      expect(fb2.foo(1, 2)).to eq 6
      expect(fb1.__send__(:__mize_cache__)).not_to be_empty
      expect(fb2.__send__(:__mize_cache__)).not_to be_empty
    end

    it 'can cache protected methods' do
      expect(fb1.__send__(:__mize_cache__)).to be_empty
      expect(fb2.__send__(:__mize_cache__)).to be_empty
      expect(fb1.__send__(:footsie, 1, 2)).to eq 1
      expect(fb2.__send__(:footsie, 1, 2)).to eq 2
      expect(fb1.__send__(:footsie, 1, 2, 3)).to eq 3
      expect(fb2.__send__(:footsie, 1, 2, 3)).to eq 4
      expect(fb1.__send__(:footsie, 1, 2)).to eq 1
      expect(fb2.__send__(:footsie, 1, 2)).to eq 2
      fb1.mize_cache_clear
      fb2.mize_cache_clear
      expect(fb1.__send__(:__mize_cache__)).to be_empty
      expect(fb2.__send__(:__mize_cache__)).to be_empty
      expect(fb1.__send__(:footsie, 1, 2)).to eq 5
      expect(fb2.__send__(:footsie, 1, 2)).to eq 6
      expect(fb1.__send__(:footsie, 1, 2)).to eq 5
      expect(fb2.__send__(:footsie, 1, 2)).to eq 6
      expect(fb1.__send__(:__mize_cache__)).not_to be_empty
      expect(fb2.__send__(:__mize_cache__)).not_to be_empty
    end
  end

  context 'memoize function' do
    it 'can cache functions' do
      expect(FooBar.__send__(:__mize_cache__)).to be_empty
      expect(fb1.bar(1, 2)).to eq 1
      expect(fb2.bar(1, 2)).to eq 1
      expect(fb1.bar(1, 2, 3)).to eq 2
      expect(fb2.bar(1, 2, 3)).to eq 2
      expect(fb1.bar(1, 2)).to eq 1
      expect(fb2.bar(1, 2)).to eq 1
      FooBar.mize_cache_clear
      expect(fb1.bar(1, 2)).to eq 3
      expect(fb2.bar(1, 2)).to eq 3
      expect(FooBar.__send__(:__mize_cache__)).not_to be_empty
    end

    it 'can cache private functions' do
      expect(FooBar.__send__(:__mize_cache__)).to be_empty
      expect(fb1.__send__(:baz, 1, 2)).to eq 1
      expect(fb2.__send__(:baz, 1, 2)).to eq 1
      expect(fb1.__send__(:baz, 1, 2, 3)).to eq 2
      expect(fb2.__send__(:baz, 1, 2, 3)).to eq 2
      expect(fb1.__send__(:baz, 1, 2)).to eq 1
      expect(fb2.__send__(:baz, 1, 2)).to eq 1
      FooBar.mize_cache_clear
      expect(fb1.__send__(:baz, 1, 2)).to eq 3
      expect(fb2.__send__(:baz, 1, 2)).to eq 3
      expect(FooBar.__send__(:__mize_cache__)).not_to be_empty
    end
  end
end
