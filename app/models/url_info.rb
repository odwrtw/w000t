# Url model info
class UrlInfo
  include Mongoid::Document
  include TypableUrl

  after_save :create_task

  field :http_code, type: Integer
  field :number_of_checks, type: Integer, default: 0
  field :last_check, type: Time

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

  def url
    w000t.long_url
  end

  private

  def parse_uri
    URI.parse(w000t.long_url)
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
end
