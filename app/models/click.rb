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

  after_validation :geocode,
                   if: ->(obj) { obj.ip.present? && obj.ip_changed? } # auto-fetch coordinates
  after_validation :reverse_geocode,
                   if: ->(obj) { obj.ip.present? && obj.ip_changed? } # auto-fetch address

  # Association
  embedded_in :w000t
end
