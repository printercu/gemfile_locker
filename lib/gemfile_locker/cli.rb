# frozen_string_literal: true

require 'thor'

module GemfileLocker
  class CLI < Thor
    class_option :gemfile,
      aliases: '-g',
      desc: 'Path to gemfile. Default: gems.rb or Gemfile (detected)'

    desc 'lock [gem ...] [options]', 'Lock all missing versions or specified gems.'
    method_option :loose,
      aliases: '-l',
      lazy_default: 'patch',
      enum: %w[major minor patch full],
      desc: 'Lock with `~>`. Optionaly provide level (default to patch)'
    method_option :except,
      aliases: '-e',
      type: :array,
      desc: 'List of gems to skip'
    method_option :force,
      aliases: '-f',
      type: :boolean,
      desc: 'Overwrite version definitions'
    def lock(*only)
      processor_opts = only.any? ? options.merge(only: only) : options
      run_editor gemfile, Locker.new(File.read(lockfile), processor_opts)
    end

    desc 'unlock [gem ...] [options]', 'Unock all or specified gems.'
    method_option :except,
      aliases: '-e',
      type: :array,
      desc: 'List of gems to skip'
    def unlock(*only)
      processor_opts = only.any? ? options.merge(only: only) : options
      run_editor gemfile, Unlocker.new(processor_opts)
    end

    private

    def run_editor(file, processor)
      editor = FileEditor.new(file, processor)
      editor.run
    end

    def gemfile
      @gemfile ||= options[:gemfile] ||
        File.exist?('gems.rb') && 'gems.rb' ||
        'Gemfile'
    end

    def lockfile
      gemfile == 'gems.rb' ? 'gems.locked' : "#{gemfile}.lock"
    end
  end
end
