# Workers
class UrlLifeChecker
  include Sidekiq::Worker

  def perform(w000t_id)
    w = W000t.find(w000t_id)
    w.url_info.update_http_code
    w.url_info.increase_number_of_checks
    w.url_info.update_last_check
    w.url_info.update_linked_w000t
  end
end
