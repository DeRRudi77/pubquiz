source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.9"

gem 'bcrypt', '~> 3.1.7'
gem "bootsnap", ">= 1.4.4", require: false
gem "devise", "~> 4.9"
gem "jsbundling-rails", "~> 1.3"
gem "pg", "~> 1.5"
gem "puma", "~> 6.0"
gem "rails", "~> 7.1.0"
gem "redis", "~> 5.0"
gem "sassc-rails", "~> 2.1"
gem "slim", "~> 4.1"
gem "sprockets-rails", ">= 3.4.0"
gem "stimulus-rails", "~> 1.3"
gem "turbo-rails", "~> 1.5"

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  # Rails 7.1's test runner is incompatible with minitest 6; pin to 5.x.
  gem "minitest", "~> 5.25"
  gem "standard"
  gem "lefthook", require: false
end

group :development do
  gem "annotate"
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 4.1.0"
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "rack-mini-profiler", "~> 2.0"
  gem "listen", "~> 3.3"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 3.26"
  # Selenium 4.11+ ships Selenium Manager, which auto-resolves drivers (replaces webdrivers gem)
  gem "selenium-webdriver", ">= 4.11"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
