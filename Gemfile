source 'https://rubygems.org'

# ROR
ruby '2.1.4'
gem 'rails', '4.1.2'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'jquery-turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# MongoDB
gem 'mongoid', '~> 4', github: 'mongoid/mongoid'
gem 'mongoid_rails_migrations'
gem 'bson_ext'

# Authentication helper
gem 'devise', '~> 3.3.0'

# Pagination helper
gem 'kaminari'

# Tags
gem 'mongoid_taggable'

# Sidekiq + Web UI
gem 'sidekiq'
gem 'sinatra', require: false
gem 'slim'

# Notifications
gem 'rushover'
gem 'flowdock'

# Monitoring
gem 'newrelic_rpm'

group :development, :test do
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'pry'

  # Replace fixtures
  gem 'factory_girl_rails'

  # Better stack straces
  gem "better_errors"
  gem "binding_of_caller"

  # Use debugger
  # gem 'debugger', group: [:development, :test]

  # Restart proccess if the code change
  # Ex for sidekiq
  # bundle exec rerun --background --dir app,db,lib --pattern '{**/*.rb}' -- bundle exec sidekiq --verbose
  # Or for reloading rais server on config change
  # rerun --dir config rails s
  gem 'rerun'

  # OS X specific gem to listen to file change
  gem 'rb-fsevent'
end

gem 'mina'
gem 'mina-sidekiq'
gem 'rb-readline'
