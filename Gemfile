source 'https://rubygems.org'

# ROR
ruby '2.6.4'
gem 'rails', '~> 6.0'
gem 'activemodel'
gem 'actionpack'
gem 'activesupport'

gem 'sprockets', '~> 3.7.2'

# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'rails-controller-testing'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', group: :doc

# MongoDB
gem 'mongoid'
gem 'mongoid_rails_migrations', git: 'https://github.com/adacosta/mongoid_rails_migrations.git'
gem 'bson_ext'

gem 'tzinfo-data'

# Geocoder
gem 'geocoder'

# Authentication helper
gem 'devise'

# Pagination helper
gem 'kaminari'
gem 'kaminari-mongoid'

# Tags
gem 'mongoid_taggable'

# Sidekiq + Web UI
gem 'sidekiq'
gem 'sinatra', require: false
gem 'slim'

gem 'redis-namespace'

# Notifications
gem 'rushover'

# Monitoring
gem 'newrelic_rpm'

# Graph
gem 'chartkick'

# Image
gem 'carrierwave-mongoid', require: 'carrierwave/mongoid'
gem 'rmagick'
gem 'fog-openstack'

group :test do
  gem 'rspec-sidekiq'
end

group :development, :test do
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'pry'

  # Replace fixtures
  gem 'factory_bot_rails'

  # Better stack straces
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'database_cleaner'

  # Use debugger
  # gem 'debugger', group: [:development, :test]

  # Restart proccess if the code change
  # Ex for sidekiq
  # bundle exec rerun --background --dir app,db,lib --pattern '{**/*.rb}' --
  # bundle exec sidekiq --verbose
  # Or for reloading rais server on config change
  # rerun --dir config rails s
  gem 'rerun'
  gem 'guard'
  gem 'guard-rspec'
  gem 'json_spec'
  # rspec doesn't support rails 6 properly yet, only in v4
  gem 'rspec-rails', '4.0.0.beta3'
  gem 'json'

  gem 'webmock'

  # OS X specific gem to listen to file change
  gem 'rb-fsevent'

  # Load conf from .env file
  gem 'dotenv-rails'

  gem 'capybara'
end

# Deployment
gem 'mina'
gem 'mina-sidekiq'
gem 'rb-readline'

# Crontab
gem 'whenever', require: false
