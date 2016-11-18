require 'aruba/rspec'

RSpec.describe GemfileLocker::CLI, type: :aruba do
  subject { -> { run_simple "gemfile_locker #{action} #{args}" } }
  let(:args) { '' }

  describe '#lock' do
    let(:action) { :lock }
    context 'for Gemfile' do
      before do
        write_file 'Gemfile', read_fixture('Gemfile')
        write_file 'Gemfile.lock', read_fixture('Gemfile.lock')
        aruba.config.activate_announcer_on_command_failure = [:stdout]
      end

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
    end
  end
end
