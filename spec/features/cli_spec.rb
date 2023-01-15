# frozen_string_literal: true

require 'aruba/rspec'

RSpec.describe GemfileLocker::CLI, type: :aruba do
  subject { -> { run_command_and_stop "gemfile_locker #{action} #{args}" } }
  let(:args) { '' }
  let(:gemfile) { 'Gemfile' }
  let(:lockfile) { "#{gemfile}.lock" }
  before do
    write_file gemfile, read_fixture('Gemfile')
    aruba.config.activate_announcer_on_command_failure = %i[stdout stderr]
  end

  shared_examples 'lock' do |**options|
    it 'locks strictly' do
      should_not raise_error
      expect(read(gemfile).join("\n")).to eq <<~RUBY
        source 'https://rubygems.org'

        gemspec

        gem 'gem-1', '1.2.3'
        gem 'gem-2', '~> 2.3.0'
        gem 'gem-3', '3.1.3.1', require: false
        gem 'gem-4', '4', platforms: [:mri],
          require: false

        group :group do
          gem 'gem-5', '5.4.3'
        end
      RUBY
    end

    context 'with -f' do
      let(:args) { '-f' }
      it 'locks strictly' do
        should_not raise_error
        expect(read(gemfile).join("\n")).to eq <<~RUBY
          source 'https://rubygems.org'

          gemspec

          gem 'gem-1', '1.2.3'
          gem 'gem-2', '2.3.4'
          gem 'gem-3', '3.1.3.1', require: false
          gem 'gem-4', '4.5.6', platforms: [:mri],
            require: false

          group :group do
            gem 'gem-5', '5.4.3'
          end
        RUBY
      end
    end

    context 'with specified gems, loose mode and custom gemfile' do
      let(:args) { "gem-1 gem-5 -l minor -g #{gemfile}" }
      let(:gemfile) { options[:custom_gemfile] }
      let(:lockfile) { options[:custom_lockfile] }

      it 'locks them with ~>' do
        should_not raise_error
        expect(read(gemfile).join("\n")).to eq <<~RUBY
          source 'https://rubygems.org'

          gemspec

          gem 'gem-1', '~> 1.2'
          gem 'gem-2', '~> 2.3.0'
          gem 'gem-3', require: false
          gem 'gem-4', '4', platforms: [:mri],
            require: false

          group :group do
            gem 'gem-5', '~> 5.4'
          end
        RUBY
      end
    end
  end

  describe '#lock' do
    let(:action) { :lock }
    before { write_file(lockfile, read_fixture('Gemfile.lock')) }

    include_examples 'lock', custom_gemfile: 'Gemfile-2', custom_lockfile: 'Gemfile-2.lock'

    context 'for bundler 2+' do
      let(:gemfile) { 'gems.rb' }
      let(:lockfile) { 'gems.locked' }
      include_examples 'lock', custom_gemfile: 'gems-2.rb', custom_lockfile: 'gems-2.rb.lock'
    end
  end

  shared_examples 'unlock' do |**options|
    it 'unlocks all' do
      should_not raise_error
      expect(read(gemfile).join("\n")).to eq <<~RUBY
        source 'https://rubygems.org'

        gemspec

        gem 'gem-1'
        gem 'gem-2'
        gem 'gem-3', require: false
        gem 'gem-4', platforms: [:mri],
          require: false

        group :group do
          gem 'gem-5'
        end
      RUBY
    end

    context 'with specified gems, custom gemfile' do
      let(:args) { "gem-1 gem-2 -g #{gemfile}" }
      let(:gemfile) { options[:custom_gemfile] }

      it 'unlocks them' do
        should_not raise_error
        expect(read(gemfile).join("\n")).to eq <<~RUBY
          source 'https://rubygems.org'

          gemspec

          gem 'gem-1'
          gem 'gem-2'
          gem 'gem-3', require: false
          gem 'gem-4', '4', platforms: [:mri],
            require: false

          group :group do
            gem 'gem-5'
          end
        RUBY
      end
    end
  end

  describe '#unlock' do
    let(:action) { :unlock }

    include_examples 'unlock', custom_gemfile: 'Gemfile-2'

    context 'for bundler 2+' do
      let(:gemfile) { 'gems.rb' }
      include_examples 'unlock', custom_gemfile: 'gems-2.rb'
    end
  end
end
