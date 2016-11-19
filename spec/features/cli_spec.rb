require 'aruba/rspec'

RSpec.describe GemfileLocker::CLI, type: :aruba do
  subject { -> { run_simple "gemfile_locker #{action} #{args}" } }
  let(:args) { '' }
  let(:gemfile) { 'Gemfile' }
  before do
    write_file gemfile, read_fixture('Gemfile')
    aruba.config.activate_announcer_on_command_failure = [:stdout, :stderr]
  end

  describe '#lock' do
    let(:action) { :lock }
    before { write_file "#{gemfile}.lock", read_fixture('Gemfile.lock') }

    it 'locks strictly' do
      should_not raise_error
      expect(read('Gemfile').join("\n")).to eq <<-RUBY.strip_heredoc
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
        expect(read('Gemfile').join("\n")).to eq <<-RUBY.strip_heredoc
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
      let(:gemfile) { 'Gemfile-2' }

      it 'locks them with ~>' do
        should_not raise_error
        expect(read('Gemfile-2').join("\n")).to eq <<-RUBY.strip_heredoc
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

  describe '#unlock' do
    let(:action) { :unlock }

    it 'unlocks all' do
      should_not raise_error
      expect(read('Gemfile').join("\n")).to eq <<-RUBY.strip_heredoc
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
      let(:gemfile) { 'Gemfile-2' }

      it 'unlocks them' do
        should_not raise_error
        expect(read('Gemfile-2').join("\n")).to eq <<-RUBY.strip_heredoc
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
end
