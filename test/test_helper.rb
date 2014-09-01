ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

module ActiveSupport
  # Test module
  class TestCase
    # Add more helper methods to be used by all tests here...
    Mongoid.load!('./config/mongoid.yml')
  end
end

module ActionController
  # Devise helper for tests
  class TestCase
    include Devise::TestHelpers
  end
end
