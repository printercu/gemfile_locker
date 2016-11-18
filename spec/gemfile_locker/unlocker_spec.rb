RSpec.describe GemfileLocker::Unlocker do
  describe '#call' do
    subject { ->(val = input, opt = options) { described_class.new(opt).call(val) } }
    let(:options) { {} }
    let(:input) { "gem 'gem-1', '1', require: false\n  gem 'gem-2', '2'" }
    its(:call) { should eq "gem 'gem-1', require: false\n  gem 'gem-2'" }

    context 'when :only is given' do
      let(:options) { {only: ['gem-2']} }
      its(:call) { should eq "gem 'gem-1', '1', require: false\n  gem 'gem-2'" }
    end

    context 'when :except is given' do
      let(:options) { {except: ['gem-2']} }
      its(:call) { should eq "gem 'gem-1', require: false\n  gem 'gem-2', '2'" }
    end
  end
end
