# Url model info
class UrlInfo
  include Mongoid::Document
  include TypableUrl

  before_validation :check_http_prefix

  field :http_code, type: Integer
  field :content_length, type: Integer
  field :number_of_checks, type: Integer, default: 0
  field :last_check, type: Time
  field :url
  field :cloud_image_urls, type: Hash

  # Image
  mount_uploader :cloud_image, ImageUploader

  # Model validation
  validates :url, presence: true, format: { with: %r{\Ahttps?:\/\/.+\Z} }

  # Association
  embedded_in :w000t

  def active?
    return true if http_code.nil?
    http_code >= 100 && http_code < 400 && (return true)
    false
  end

  def update_http_code
    uri = parse_uri
    logger.info "URI #{uri}"
    head = head_request(uri) if uri
    logger.info "head #{head.inspect}"
    if head
      self.http_code = head.code ? head.code : 500
      self.content_length = head.content_length ? head.content_length : 0
    else
      self.http_code = 500
      self.content_length = 0
    end
    save
  end

  def increase_number_of_checks
    inc(number_of_checks: 1)
  end

  def update_last_check
    touch(:last_check)
  end

  def update_linked_w000t
    if active?
      w000t.restore!
    else
      w000t.archive!
    end
  end

  def store_in_cloud
    unless w000t.user
      logger.info "Don't store, it's a public w000t"
      return
    end
    unless http_code == 200
      logger.info "Don't store, not an http_code 200 OK (#{http_code})"
      return
    end
    if (!content_length) || content_length > 1.megabytes
      logger.info "Don't store, not valid content_length  #{content_length}"
      return
    end
    if type == 'image'
      logger.info "----- In url_info #{id} with w000t :  #{w000t.id}"
      CloudImageUploader.perform_async(w000t._id)
    else
      logger.info "Don't upload because of type #{type}"
    end
  end

  # Add http prefix if needed
  def self.prefixed_url(url)
    return url if /\Ahttp/ =~ url

    # Add prefix
    'http://' + url
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
    http.read_timeout = 10
    http.start { |r| r.head(uri.path.size > 0 ? uri.path : '/') }
  rescue
    logger.info "ERROR when requesting url => #{$ERROR_INFO}"
    nil
  end

  # Add http prefix if needed
  def check_http_prefix
    return unless url
    return if /\Ahttp/ =~ url

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
