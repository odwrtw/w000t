# config/initializers/carrierwave.rb

CarrierWave.configure do |config|
  config.storage = :fog
  if Rails.env.development?
    config.fog_credentials = {
      provider: 'OpenStack',
      openstack_tenant: '98091111',
      openstack_username: 'pouulet@gmail.com',
      openstack_api_key:  'the_dummy_password!',
      openstack_auth_url: 'https://auth.runabove.io/v2.0/tokens',
      openstack_region: 'SBG-1'
    }
    config.fog_directory  = 'test_directory'
  else
    config.fog_credentials = {
      provider: 'OpenStack',
      openstack_tenant: ENV['OPENSTACK_TENANT'],
      # Your OpenStack Username
      openstack_username: ENV['OPENSTACK_USERNAME'],
      # Your OpenStack Password
      openstack_api_key:  ENV['OPENSTACK_API_KEY'],
      openstack_auth_url: ENV['OPENSTACK_AUTH_URL'],
      openstack_region: ENV['OPENSTACK_REGION']
    }
    config.fog_directory  = ENV['FOG_DIRECTORY']
    config.asset_host  = ENV['OPENSTACK_ASSET_HOST']
  end
  config.fog_public     = true         # optional, defaults to true
  config.fog_attributes = {
    'Cache-Control' => "max-age=#{365.day.to_i}"
  }
end
