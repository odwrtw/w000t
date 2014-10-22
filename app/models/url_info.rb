# Url model info
class UrlInfo
  include Mongoid::Document
  include TypableUrl

  after_create :create_task
  before_validation :check_http_prefix

  field :http_code, type: Integer
  field :number_of_checks, type: Integer, default: 0
  field :last_check, type: Time
  field :url

  # Model validation
  validates :url, presence: true, format: { with: %r{\Ahttps?:\/\/.+\Z} }

  # Association
  embedded_in :w000t

  def create_task
    UrlLifeChecker.perform_async(w000t._id)
  end

  def active?
    return true if http_code.nil?
    http_code >= 100 && http_code < 400 && (return true)
    false
  end

  def update_http_code
    uri = parse_uri
    code = head_request(uri) if uri
    self.http_code = code ? code : 500
    save!
  end

  def increase_number_of_checks
    inc(number_of_checks: 1)
  end

  def update_last_check
    touch(:last_check)
  end

  def update_linked_w000t
    if self.active?
      w000t.restore!
    else
      w000t.archive!
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
      nil
  end

  def head_request(uri)
    response = nil
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.read_timeout = 10
    http.start { |r| response = r.head(uri.path.size > 0 ? uri.path : '/') }
    response.code
  rescue
    nil
  end

  # Add http prefix if needed
  def check_http_prefix
    return unless url
    return if /\Ahttp/ =~ url

    # Add prefix
    self.url = UrlInfo.prefixed_url(url)
  end
end
