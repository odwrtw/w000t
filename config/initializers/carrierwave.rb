# config/initializers/carrierwave.rb
require 'carrierwave/storage/fog'

CarrierWave.configure do |config|
  config.storage = :file
  config.cache_storage = :file
end
