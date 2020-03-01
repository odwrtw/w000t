# config/initializers/carrierwave.rb
require 'carrierwave/storage/fog'

CarrierWave.configure do |config|
  if not Rails.env.production?
    config.storage = :file
    config.cache_storage = :file
  else
    config.storage = :fog
    config.cache_storage = :file
    config.fog_credentials = {
      provider: 'OpenStack',
      # Your OpenStack Username
      openstack_username:     ENV['OPENSTACK_USERNAME'],
      # Your OpenStack Password
      openstack_api_key:      ENV['OPENSTACK_API_KEY'],
      openstack_auth_url:     ENV['OPENSTACK_AUTH_URL'],
      openstack_region:       ENV['OPENSTACK_REGION'],
      openstack_domain_id:    ENV['OPENSTACK_DOMAIN_ID'],
      openstack_project_name: ENV['OPENSTACK_PROJECT_NAME']
    }
    config.fog_directory    = ENV['FOG_DIRECTORY']
    config.asset_host       = ENV['OPENSTACK_ASSET_HOST']
    config.fog_public       = true
    config.fog_attributes   = {
      'Cache-Control' => "max-age=#{365.days.to_i}"
    }
  end
end
