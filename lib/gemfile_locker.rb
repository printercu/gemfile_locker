require 'gemfile_locker/version'

module GemfileLocker
  autoload :CLI, 'gemfile_locker/cli'
  autoload :FileEditor, 'gemfile_locker/file_editor'
  autoload :GemfileProcessor, 'gemfile_locker/gemfile_processor'
  autoload :Locker, 'gemfile_locker/locker'
  autoload :Unlocker, 'gemfile_locker/unlocker'
end
