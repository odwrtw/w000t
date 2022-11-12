# w000t model
class W000t
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Taggable
  include ActionView::Helpers::TextHelper
  require 'digest/sha1'

  STATUS = %i( private hidden public )

  # Callbacks
  before_save :create_short_url
  after_create :create_task

  attr_accessor :long_url
  attr_accessor :upload_image

  # DB fields
  field :_id, as: :short_url
  field :status, type: Symbol, default: :public
  field :user_id, type: Integer
  field :number_of_click, type: Integer, default: 0
  field :archive, type: Integer, default: 0

  # Indexes
  index({ short_url: 1 }, unique: true, name: 'w000t_index_on_short_url')
  index({ status: 1 }, name: 'w000t_index_on_status')
  index({ archive: 1 }, name: 'w000t_index_on_archive')
  index({ user_id: 1 }, name: 'user_index_on_id')

  index({ 'url_info.url' => 1 }, name: 'url_index_on_url')
  index(
    { user_id: 1, 'url_info.url' => 1 },
    unique: true, name: 'user_url_unique_index'
  )

  # Association
  embeds_one :url_info, cascade_callbacks: true
  accepts_nested_attributes_for :url_info

  embeds_many :clicks, cascade_callbacks: true
  accepts_nested_attributes_for :clicks

  # Model validation
  validates :status, presence: true, inclusion: { in: STATUS }

  belongs_to :user, optional: true
  delegate :pseudo, :email, to: :user, prefix: true
  delegate :url, :http_code, :number_of_checks, :type,
           :last_check, to: :url_info, prefix: true

  scope :by_type, ->(type) { where('url_info.type' => type) }
  scope :by_status, ->(status) { where('url_info.status' => status) }
  scope :of_owner_wall, -> {
    by_type('image').and(archive: 0).ne(status: :hidden).only(:status, :user_id, 'url_info.$')
  }
  scope :of_public_wall, -> {
    by_type('image').and(archive: 0).and(status: :public).only(:status, :user_id, 'url_info.$')
  }

  def create_task
    if url_info.internal_status == :to_upload
      # If internal_status is to_upload, need to create UploadChecker
      UploadChecker.perform_async(_id)
    else
      # Else, simply create UrlLifeChecker
      UrlLifeChecker.perform_async(_id)
    end
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
    archive
    save
  end

  def archive
    self.archive = 1
  end

  def restore!
    restore
    save
  end

  def restore
    self.archive = 0
  end

  def initialize(attributes = {})
    super

    params = {
      url: long_url,
      cloud_image: upload_image
    }
    build_url_info(params)
  end

  # Click updates the w000t when clicked
  def click(ip_address)
    # Add the clicks
    clicks.new(ip: ip_address)
    # Increments the number of clicks
    self.number_of_click += 1
    save
  end

  def img_path
    url_info.img_path
  end

  def url
    return url if url_info.url
    url_info.img_path
  end

  private

  # Create short url on save if not yet defined
  def create_short_url
    return if short_url
    # Check if the required parameters are present
    unless upload_image || long_url
      logger.info "url : #{url_info.inspect} self : #{inspect}"
      raise 'Missing long_url or upload_image'
    end

    self.long_url = url_info.id if long_url.blank?

    to_hash = long_url.to_s

    # Custom hash if the user is logged in
    to_hash = user.pseudo + 'pw3t' + long_url if user_id

    # And we keep only the 10 first characters
    self._id = hash_and_truncate(to_hash)
  end
end
