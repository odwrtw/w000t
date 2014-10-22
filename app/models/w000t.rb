# w000t model
class W000t
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActionView::Helpers::TextHelper
  require 'digest/sha1'

  # Callbacks
  before_save :create_short_url
  after_initialize :build_embedded_url

  # DB fields
  field :_id, as: :short_url
  field :long_url
  field :user_id, type: Integer
  field :number_of_click, type: Integer, default: 0
  field :archive, type: Integer, default: 0

  # Model validation
  validates :long_url, presence: true, format: { with: %r{\Ahttps?:\/\/.+\Z} }

  # Association
  # FIX: type should be set on w000t.create
  embeds_one :url_info, cascade_callbacks: true

  belongs_to :user
  delegate :pseudo, :email, to: :user, prefix: true
  delegate :url, :http_code, :number_of_checks,
           :last_check, to: :url_info, prefix: true

  # Define the short_url as the id of the model
  def to_param
    short_url
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

  private

  # Create short url on save if not yet defined
  def create_short_url
    # Don't redefine the short_url
    return if short_url

    # Hash the long_url by default
    to_hash = long_url

    # Custom hash if the user is logged in
    to_hash = user.pseudo + 'pw3t' + long_url if user_id

    # And we keep only the 10 first characters
    self._id = hash_and_truncate(to_hash)
  end

  def build_embedded_url
    build_url_info
  end
end
