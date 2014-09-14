# Workers
class UrlLifeChecker
  include Sidekiq::Worker

  def perform(long_url)
    url = UrlInfo.find_by(url: long_url)
    url = UrlInfo.create(url: long_url) unless url
    url.update_http_code!
    url.increase_number_of_checks!
    url.update_last_check!
    url.update_linked_w000ts!
  end
end
