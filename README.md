# Maxima

Welcome to `ruby`'s best Maxima integration!

Ruby developers have, for as long as I can remember, had a disheveled heap of scientific and mathematical libraries - many of which operate in pure ruby code. Given a problem we either kludge together some cobbled mess or turn to Python/R/etc. And to this I say no more! rb_maxima allows a ruby developer to directly leverage the unbridled power of the open source, lisp powered, computer algebra system that is Maxima!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rb_maxima'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rb_maxima

### Install Maxima

#### macOS

    $ brew install maxima

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/danieth/rb_maxima.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
