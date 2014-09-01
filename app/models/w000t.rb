# w000t model
class W000t
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActionView::Helpers::TextHelper
  require 'digest/sha1'

  field :long_url
  field :short_url
  field :user_id, type: Integer
  field :number_of_click, type: Integer, default: 0

  belongs_to :user

  delegate :pseudo, :email, to: :user, prefix: true

  # field :_id, type: String, default: ->{ short_url }
  def to_param
    short_url
  end

  def shorten_url(long_url)
    to_hash = long_url

    # Custom hash if the user is logged in
    to_hash = user.pseudo + 'pw3t' + long_url if user_id

    # We hash the long_url
    short_url = Digest::SHA1.hexdigest to_hash

    # And we keep only the 10 first characters
    self.short_url = truncate(short_url, length: 10, omission: '')
  end

  # Takes the base url and return the full shortened path
  def full_shortened_url(base)
    base + '/' + short_url
  end
end
