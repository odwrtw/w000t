# config/initializers/carrierwave.rb

CarrierWave.configure do |config|
  if Rails.env.test?
    config.storage = :file
    config.fog_credentials[:provider] = 'OpenStack'
  else
    config.storage = :fog
    config.fog_credentials = {
      provider: 'OpenStack',
      openstack_tenant:       ENV['OPENSTACK_TENANT'],
      # Your OpenStack Username
      openstack_username:     ENV['OPENSTACK_USERNAME'],
      # Your OpenStack Password
      openstack_api_key:      ENV['OPENSTACK_API_KEY'],
      openstack_auth_url:     ENV['OPENSTACK_AUTH_URL'] || 'https://auth.runabove.io/v2.0/tokens',
      openstack_region:       ENV['OPENSTACK_REGION']
    }
    config.fog_directory = 'bucket_name'
    config.fog_public       = true
    config.fog_attributes   = {
      'Cache-Control' => "max-age=#{365.days.to_i}"
    }
  end
end
