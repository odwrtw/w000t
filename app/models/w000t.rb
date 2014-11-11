# w000t model
class W000t
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Taggable
  include ActionView::Helpers::TextHelper
  require 'digest/sha1'

  # Callbacks
  before_save :create_short_url
  after_create :create_task

  attr_accessor :long_url

  # DB fields
  field :_id, as: :short_url
  field :user_id, type: Integer
  field :number_of_click, type: Integer, default: 0
  field :archive, type: Integer, default: 0
  field :long_url, as: :old_long_url, type: String

  # Indexes
  index({ short_url: 1 }, { unique: true, name: 'short_url_index' })

  # Association
  embeds_one :url_info, cascade_callbacks: true

  accepts_nested_attributes_for :url_info

  belongs_to :user
  delegate :pseudo, :email, to: :user, prefix: true
  delegate :url, :http_code, :number_of_checks, :type,
           :last_check, to: :url_info, prefix: true

  scope :by_type, ->(type) { where('url_info.type' => type) }

  def create_task
    UrlLifeChecker.perform_async(_id)
  end

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

  def initialize(attributes = {})
    super
    build_url_info(url: long_url)
  end

  private

  # Create short url on save if not yet defined
  def create_short_url
    # Don't redefine the short_url
    return if short_url

    # Hash the long url by default
    to_hash = long_url

    # Custom hash if the user is logged in
    to_hash = user.pseudo + 'pw3t' + long_url if user_id

    # And we keep only the 10 first characters
    self._id = hash_and_truncate(to_hash)
  end
end
