describe Mize do
  describe '.synchronize' do
    it 'executes the block and returns its value' do
      expect(described_class.synchronize { 42 }).to eq(42)
    end

    it 'is the same lock object as Mize::MUTEX' do
      expect {
        Mize::MUTEX.synchronize { Mize.synchronize { :x } }
      }.to raise_error(ThreadError)
    end
  end
end
