require 'thor'

module GemfileLocker
  class CLI < Thor
    class_option :gemfile,
      aliases: '-g',
      default: 'Gemfile',
      desc: 'Path to gemfile'

    desc 'lock [gem ...] [options]', 'Lock all missing versions or specified gems.'
    method_option :loose,
      aliases: '-l',
      lazy_default: 'patch',
      enum: %w(major minor patch full),
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
      gemfile = options[:gemfile]
      lockfile = File.read("#{gemfile}.lock")
      processor_opts = only.any? ? options.merge(only: only) : options
      run_editor gemfile, Locker.new(lockfile, processor_opts)
    end

    desc 'unlock [gem ...] [options]', 'Unock all or specified gems.'
    method_option :except,
      aliases: '-e',
      type: :array,
      desc: 'List of gems to skip'
    def unlock(*only)
      processor_opts = only.any? ? options.merge(only: only) : options
      run_editor options[:gemfile], Unlocker.new(processor_opts)
    end

    private

    def run_editor(file, processor)
      editor = FileEditor.new(file, processor)
      editor.run
    end
  end
end
