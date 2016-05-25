# Click model info
class Click
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  field :ip
  field :coordinates, type: Array
  field :address

  # Fetch coordinates from the IP
  geocoded_by :ip
  # Fetch the address from the coordinates
  reverse_geocoded_by :coordinates

  after_validation :geocode          # auto-fetch coordinates
  after_validation :reverse_geocode  # auto-fetch address

  # Association
  embedded_in :w000t
end
