# frozen_string_literal: true

RSpec.describe GemfileLocker::Locker do
  let(:lockfile) { <<~TXT }
    GEM
      remote: https://rubygems.org/
      specs:
        gem-1 (1.2.3.4)
          gem-1-1 (~> 1)
          gem-2 (~> 2.2.2)
        gem-2 (2.3.4)

    GIT
      remote: https://repo.git
      revision: 09876543210987654321
      ref: some-tag
      specs:
        gem-3 (3.2.1)

    GIT
      remote: https://other-repo.git
      revision: 12345678901234567890
      specs:
        gem-4 (4.1.2)
  TXT

  describe '#call' do
    subject do
      lambda do |val = input, lock = lockfile, opt = options|
        described_class.new(lock, opt).call(val)
      end
    end
    let(:options) { {} }
    let(:input) { %(gem 'gem-1', require: false\n  gem "gem-2") }
    it 'locks versions' do
      expect(subject[input, lockfile, options]).
        to eq %(gem 'gem-1', '1.2.3.4', require: false\n  gem "gem-2", "2.3.4")
      expect(subject[%(gem 'gem-1'), lockfile, options]).
        to eq %(gem 'gem-1', '1.2.3.4')
      expect(subject[%(gem 'gem-1'\ngem 'gem-2'), lockfile, options]).
        to eq %(gem 'gem-1', '1.2.3.4'\ngem 'gem-2', '2.3.4')
    end

    context 'when :only is given' do
      let(:options) { {only: ['gem-1']} }
      its(:call) { should eq %(gem 'gem-1', '1.2.3.4', require: false\n  gem "gem-2") }
    end

    context 'when :except is given' do
      let(:options) { {except: ['gem-1']} }
      its(:call) { should eq %(gem 'gem-1', require: false\n  gem "gem-2", "2.3.4") }
    end

    context 'when :loose given' do
      it 'use ~> definition' do
        expect(subject[input, lockfile, loose: :full]).
          to eq %(gem 'gem-1', '~> 1.2.3.4', require: false\n  gem "gem-2", "~> 2.3.4")
        expect(subject[input, lockfile, loose: :patch]).
          to eq %(gem 'gem-1', '~> 1.2.3', require: false\n  gem "gem-2", "~> 2.3.4")
        expect(subject[input, lockfile, loose: :minor]).
          to eq %(gem 'gem-1', '~> 1.2', require: false\n  gem "gem-2", "~> 2.3")
        expect(subject[input, lockfile, loose: :major]).
          to eq %(gem 'gem-1', '~> 1', require: false\n  gem "gem-2", "~> 2")
      end
    end

    context 'when gem has defined version' do
      let(:input) { %(gem 'gem-1', '1', require: false\n  gem "gem-2") }
      it 'locks only missing versions' do
        expect(subject[input, lockfile, options]).
          to eq %(gem 'gem-1', '1', require: false\n  gem "gem-2", "2.3.4")
        expect(subject[%(gem 'gem-1'\ngem 'gem-2', '~> 2'), lockfile, options]).
          to eq %(gem 'gem-1', '1.2.3.4'\ngem 'gem-2', '~> 2')
      end

      context 'and force: true' do
        let(:options) { {force: true} }
        its(:call) { should eq %(gem 'gem-1', '1.2.3.4', require: false\n  gem "gem-2", "2.3.4") }
      end
    end

    context 'and gem has git source' do
      it 'locks versions' do
        expect(subject[<<~RUBY]).to eq <<~RUBY
          gem 'gem-3', git: 'smth'
          gem 'gem-4'
          gem 'gem-4', tag: 'other-tag'
        RUBY
          gem 'gem-3', '3.2.1', git: 'smth', ref: 'some-tag'
          gem 'gem-4', '4.1.2', ref: '1234567'
          gem 'gem-4', '4.1.2', tag: 'other-tag'
        RUBY
      end
    end
  end
end
