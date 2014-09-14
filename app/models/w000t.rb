# w000t model
class W000t
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActionView::Helpers::TextHelper
  require 'digest/sha1'

  # Callbacks
  before_save :create_short_url

  # DB fields
  field :long_url
  field :short_url
  field :user_id, type: Integer
  field :number_of_click, type: Integer, default: 0
  field :archive, type: Integer, default: 0

  # Model validation
  validates :long_url, presence: true, format: { with: %r{\Ahttps?:\/\/.+\Z} }

  # Association
  has_one :url_info, foreign_key: 'url', primary_key: 'long_url',
                     inverse_of: :w000t
  belongs_to :user
  delegate :pseudo, :email, to: :user, prefix: true
  delegate :url, :http_code, :number_of_checks,
           :last_check, to: :url_info, prefix: true

  # Define the short_url as the id of the model
  def to_param
    short_url
  end

  # Create short url on save if not yet defined
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

  def hash_and_truncate(input_string)
    truncate(Digest::SHA1.hexdigest(input_string), length: 10, omission: '')
  end

  # Takes the base url and return the full shortened path
  def full_shortened_url(base)
    base + '/' + short_url
  end

  def archive!
    self.archive = 1
    save
  end

  def restore!
    self.archive = 0
    save
  end
end
