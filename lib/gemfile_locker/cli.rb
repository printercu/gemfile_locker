require 'thor'

module GemfileLocker
  class CLI < Thor
    desc 'lock [Gemfile]', 'Lock dependencies.'
    method_option :loose,
      aliases: '-l',
      lazy_default: 'patch',
      enum: %w(major minor patch full),
      desc: 'Lock with `~>`. Optionaly provide level (default to patch)'
    method_option :only,
      aliases: '-o',
      type: :array,
      desc: 'List of gems to process'
    method_option :except,
      aliases: '-e',
      type: :array,
      desc: 'List of gems to skip'
    method_option :force,
      aliases: '-f',
      type: :boolean,
      desc: 'Overwrite version definitions ' \
            '(By default it adds only missing version definitions)'
    def lock(file = 'Gemfile')
      lockfile = File.read("#{file}.lock")
      run_editor file, Locker.new(lockfile, options)
    end

    desc 'unlock [Gemfile]', 'Unlock dependencies.'
    method_option :only,
      aliases: '-o',
      type: :array,
      desc: 'List of gems to process'
    method_option :except,
      aliases: '-e',
      type: :array,
      desc: 'List of gems to skip'
    def unlock(file = 'Gemfile')
      run_editor file, Unlocker.new(options)
    end

    private

    def run_editor(file, processor)
      editor = FileEditor.new(file, processor)
      editor.run
    end
  end
end
