source 'https://rubygems.org'

# ROR
ruby '2.2.5'
gem 'rails', '4.1.2'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.4'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 3.0.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.1.1'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'jquery-turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.4.1'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.1', group: :doc

# MongoDB
gem 'mongoid', '~> 4'
gem 'mongoid_rails_migrations'
gem 'bson_ext'

# Geocoder
gem 'geocoder', '~> 1.3.4'

# Authentication helper
gem 'devise', '~> 4.1.0'

# Pagination helper
gem 'kaminari'

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
gem 'fog', git: 'git://github.com/fog/fog.git'

group :development, :test do
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'pry'

  # Replace fixtures
  gem 'factory_girl_rails'

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
  gem 'rspec-rails'

  gem 'fakeweb'

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
