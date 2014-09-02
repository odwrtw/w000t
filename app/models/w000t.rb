# w000t model
class W000t
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActionView::Helpers::TextHelper
  require 'digest/sha1'

  before_save :create_short_url

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

  def create_short_url
    # Don't redefine the short_url
    return if short_url

    # Hash the long_url by default
    to_hash = long_url

    # Custom hash if the user is logged in
    to_hash = user.pseudo + 'pw3t' + long_url if user_id

    # And we keep only the 10 first characters
    self.short_url = hash_and_truncate(to_hash)
  end

  # TODO move this function to the lib folder so it can be used in the tests
  # too
  def hash_and_truncate(input_string)
    truncate(Digest::SHA1.hexdigest(input_string), length: 10, omission: '')
  end

  # Takes the base url and return the full shortened path
  def full_shortened_url(base)
    base + '/' + short_url
  end

end
