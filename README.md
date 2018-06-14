# Aker - Sets client gem

[![Build Status](https://travis-ci.org/sanger/aker-sets-client-gem.svg?branch=master)](https://travis-ci.org/sanger/aker-sets-client-gem)
[![Maintainability](https://api.codeclimate.com/v1/badges/569cedb328b1c9198381/maintainability)](https://codeclimate.com/github/sanger/aker-sets-client-gem/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/569cedb328b1c9198381/test_coverage)](https://codeclimate.com/github/sanger/aker-sets-client-gem/test_coverage)

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/aker-set-client`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

There is a dependency on json_api_client that resides in Sanger's repo. This is due to an issue with the original gem not raising errors on bad requests.

To build this gem make sure you use bundler, as extra dependency is specified in Gemfile.

Add this line to your application's Gemfile:

```ruby
gem 'aker-set-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aker-set-client'

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/aker-set-client'.
