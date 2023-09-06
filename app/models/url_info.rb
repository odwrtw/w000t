# Url model info
class UrlInfo
  include Mongoid::Document
  include TypableUrl

  before_validation :check_http_prefix

  INTERNAL_STATUS = %i( todo to_upload done error )
  MAX_UPLOAD_SIZE = 2.megabytes.to_i

  field :http_code, type: Integer
  field :content_length, type: Integer
  field :number_of_checks, type: Integer, default: 0
  field :last_check, type: Time
  field :url
  field :cloud_image_urls, type: Hash
  field :internal_status, type: Symbol, default: :todo

  # Image
  mount_uploader :cloud_image, ImageUploader

  # Model validation
  validate :validates_url_or_upload_is_present
  validate :validates_url_format_is_good
  validates :internal_status, presence: true, inclusion: { in: INTERNAL_STATUS }

  # Association
  embedded_in :w000t, :inverse_of => :url_info

  def new(params = {})
    super
    logger.info "after new in url_info: #{self.inspect} with params #{params.inspect}"
  end

  def before_initialize
    logger.info "kikoo: #{self.inspect}"
    logger.info "kikoo: #{params.inspect}"
  end

  def validates_url_or_upload_is_present
    logger.info "in validated_url_or_upload_is_present with: #{self.inspect} and #{cloud_image.inspect} and #{cloud_image.file}"

    errors.add(:url, 'Should not be nil') if cloud_image.nil? && url.blank?
  end

  def validates_url_format_is_good
    return unless cloud_image.blank?
    errors.add(
      :url, 'Should begin with http or https'
    ) if !url.blank? && %r{\Ahttps?:\/\/.+\Z} !~ url
  end

  def active?
    return true if http_code.nil?
    http_code >= 100 && http_code < 400 && (return true)
    false
  end

  def update_http_code!
    update_http_code
    save
  end

  def update_http_code
    logger.info "update http code"
    if url.blank?
      logger.info "update http code - It's an image!"
      return unless cloud_image.file
      self.http_code = 200
      self.content_length = cloud_image.size
      return
    end

    uri = parse_uri
    logger.info "update http code - URI #{uri}"
    head = head_request(uri) if uri
    logger.info "update http code - head #{head.inspect}"
    if head
      self.http_code = head.code ? head.code : 500
      self.content_length = head.content_length ? head.content_length : 0
    else
      self.http_code = 500
      self.content_length = 0
    end
  end

  def increase_number_of_checks
    inc(number_of_checks: 1)
  end

  def update_last_check
    touch(:last_check)
  end

  def update_linked_w000t
    if active?
      w000t.restore
    else
      w000t.archive
    end
  end

  def update_linked_w000t!
    update_linked_w000t
    save
  end

  def store_in_cloud?
    unless w000t.user
      logger.info "store_in_cloud? Don't store, it's a public w000t"
      return false
    end

    unless http_code == 200
      logger.info "store_in_cloud? Don't store, not an http_code 200 OK (#{http_code})"
      return false
    end

    if !content_length || content_length > MAX_UPLOAD_SIZE
      logger.info "store_in_cloud? Don't store, not valid content_length  #{content_length}"
      return false
    end

    # Don't upload hidden image
    return false if w000t.status.eql? :hidden

    if type == 'image'
      logger.info "store_in_cloud? ----- In url_info #{id} with w000t :  #{w000t.id}"
      return true
    else
      logger.info "store_in_cloud? Don't upload because of type #{type}"
      return false
    end
  end

  def store_in_cloud!
    CloudImageUploader.perform_async(w000t._id)
  end

  # Add http prefix if needed
  def self.prefixed_url(url)
    return if url.blank?
    return url if /\Ahttp/ =~ url

    # Add prefix
    'http://' + url
  end

  def img_path
    if cloud_image.url.blank?
      url
    else
      cloud_image.url
    end
  end

  private

  def parse_uri
    URI.parse(url)
  rescue URI::Error
    logger.info 'Uri parse error'
    nil
  end

  def head_request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    # Timeout to open the connection
    http.open_timeout = 10
    # Timeout to read one block
    http.read_timeout = 10
    http.start { |r| r.head(uri.path.size > 0 ? uri.path : '/') }
  rescue => exception
    logger.info "ERROR when requesting url => #{exception.inspect}"
    nil
  end

  # Add http prefix if needed
  def check_http_prefix(attributes = {})
    logger.info "checking http_prefix #{self.inspect}"
    logger.info "checking http_prefix #{attributes.inspect}"
    return if /\Ahttp/ =~ url

    if cloud_image.file
      logger.info "cloud_image present"
      # self.internal_status = :to_upload
      return
    end

    # Add prefix
    self.url = UrlInfo.prefixed_url(url)
  end

  def remove_cloud_image!
    super
  rescue Fog::Storage::OpenStack::NotFound
    logger.warn "cloud_image didn't exsist, wtf?"
    true
  end

  def w000t_cloud_image_url(type)
    return cloud_image_urls[type.to_sym] if cloud_image_urls
    cloud_image.url
  end
end
