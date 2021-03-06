# GemfileLocker

[![Gem Version](https://badge.fury.io/rb/gemfile_locker.svg)](http://badge.fury.io/rb/gemfile_locker)
[![Code Climate](https://codeclimate.com/github/printercu/gemfile_locker/badges/gpa.svg)](https://codeclimate.com/github/printercu/gemfile_locker)
[![Build Status](https://travis-ci.org/printercu/gemfile_locker.svg)](https://travis-ci.org/printercu/gemfile_locker)

It can lock all (or selected) dependencies strictly or semi-strictly (with `~>`),
so it gets safe to run `bundle update` anytime.

It can also unlock dependencies so you can easily update to the latest versions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gemfile_locker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gemfile_locker

## Usage

```
gemfile_locker help [COMMAND]

gemfile_locker lock [gem ...] [options]   # Lock all missing versions or specified gems.

Options:
  -l, [--loose=LOOSE]           # Lock with `~>`. Optionaly provide level (default to patch)
                                # Possible values: major, minor, patch, full
  -e, [--except=one two three]  # List of gems to skip
  -f, [--force]                 # Overwrite version definitions
                                # (By default it adds only missing version definitions)
  -g, [--gemfile=GEMFILE]       # Path to gemfile
                                # Default: Default: gems.rb or Gemfile (detected)

gemfile_locker unlock [gem ...] [options] # Unock all or specified gems.

Options:
  -e, [--except=one two three]  # List of gems to skip
  -g, [--gemfile=GEMFILE]       # Path to gemfile
                                # Default: Default: gems.rb or Gemfile (detected)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`,
and then run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/printercu/gemfile_locker.

## License

MIT
