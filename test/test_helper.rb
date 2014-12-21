ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'sidekiq/testing'
require 'fakeweb'

module ActiveSupport
  # Test module
  class TestCase
    # Add more helper methods to be used by all tests here...
    Mongoid.load!('./config/mongoid.yml')

    # Do not connect to the web when testing
    FakeWeb.allow_net_connect = false
    # Do not log Sidekiq when testing
    Sidekiq::Logging.logger = nil

    setup do
      # Delete all users
      User.all.destroy

      # Delete all w000ts
      W000t.all.destroy

      # Delete all auth tokens
      AuthenticationToken.all.destroy

      # Clean all fakewebs
      FakeWeb.clean_registry

      # Clear sidekiq queue
      Sidekiq::Worker.clear_all
    end

    def json_response
      ActiveSupport::JSON.decode @response.body
    end

    def json_expected_keys(keys)
      keys.each do |k|
        assert json_response.key?(k), "Missing key '#{k}' in json response"
      end
    end

    def json_unexpected_keys(keys)
      keys.each do |k|
        assert_not json_response.key?(k),
                   "The key '#{k}' should not be in the json response"
      end
    end
  end
end

module ActionController
  # Devise helper for tests
  class TestCase
    include Devise::TestHelpers

    setup do
      # Set HTTP_REFERER
      request.env['HTTP_REFERER'] = 'previous_page'
    end
  end
end
