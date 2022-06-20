source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.1'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '5.6.1'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem 'hiredis'
gem 'redis', '~> 4.0'
gem 'redis-namespace'

gem 'graphql'
gem 'graphql-client'

gem 'keccak', '~> 1.3'

# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

gem 'image_processing', '~> 1.2'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

gem 'rails_admin', '~> 3.0.0'

gem 'blueprinter'

gem 'devise'

gem 'nio4r'

gem 'io-wait', '0.2.1'

# Storage
gem 'aws-sdk-s3', require: false

gem 'web3-eth'

# HTTP requests
gem 'httparty'

gem 'recursive-open-struct'

gem 'mobility', '~> 1.2.6'

gem 'cancancan'

gem 'rubycritic', require: false

gem 'ffi', submodules: true

# Currency Conversion
gem 'money'

gem 'sidekiq'

# Payment Gateways
gem 'stripe'

group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'vcr'
  gem 'webmock'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end
gem 'sassc-rails'
