# config/initializers/carrierwave.rb

CarrierWave.configure do |config|
  config.storage = :fog
  config.fog_credentials = {
    provider: 'OpenStack',
    openstack_tenant: ENV['OPENSTACK_TENANT'] || '98091111',
    # Your OpenStack Username
    openstack_username: ENV['OPENSTACK_USERNAME'] || 'pouulet@gmail.com',
    # Your OpenStack Password
    openstack_api_key:  ENV['OPENSTACK_API_KEY'] || 'the_dummy_password!',
    openstack_auth_url: ENV['OPENSTACK_AUTH_URL'] || 'https://auth.runabove.io/v2.0/tokens',
    openstack_region: ENV['OPENSTACK_REGION'] || 'SBG-1'
  }
  config.fog_directory  = ENV['FOG_DIRECTORY'] || ENV['RAILS_ENV'] || 'test_directory'
  config.fog_public     = true         # optional, defaults to true
  config.fog_attributes = {
    'Cache-Control' => "max-age=#{365.day.to_i}"
  }
end
