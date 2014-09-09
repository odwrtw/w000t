# Url model info
class UrlInfo
  include Mongoid::Document
  include Mongoid::Timestamps

  field :url, type: String
  field :http_code, type: Integer
  field :number_of_checks, type: Integer, default: 0
  field :last_check, type: Time

  # Model validation
  validates :url, presence: true, format: { with: %r{\Ahttps?:\/\/.+\Z} }

  # Association
  has_many :w000ts, class_name: 'W000t',
                    foreign_key: 'long_url', primary_key: 'url',
                    inverse_of: :url_info

  def active?
    return true if http_code.nil?
    http_code >= 100 && http_code < 400 && (return true)
    false
  end
end
