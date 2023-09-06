# Workers
class UrlLifeChecker
  include Sidekiq::Worker

  def perform(w000t_id)
    logger.info "=== Checking life === with id #{w000t_id}"
    w = W000t.find(w000t_id)
    unless w
      logger.info "=== Checking life === There is no w000t with id #{w000t_id}"
      raise "No w000t with id #{w000t_id}"
    end
    logger.info "=== Checking life === of url #{w.url_info.url}"
    w.url_info.update_http_code
    w.url_info.increase_number_of_checks
    w.url_info.update_last_check
    w.url_info.update_linked_w000t

    logger.info "=== Checking life === Checking done #{w.url_info.http_code}"

    w.url_info.internal_status = :done
    if not w.url_info.cloud_image.nil?
      logger.info '=== Checking life === Image already uploaded'
    elsif w.url_info.store_in_cloud?
      w.url_info.internal_status = :to_upload
      logger.info '=== Checking life === Creating store_in_cloud Task'
      fnret = w.url_info.store_in_cloud!
      logger.info "=== Checking life === Upload : #{fnret}"
    end
    w.url_info.save!
    logger.info '=== Checking life === ALL DONE'
  end
end
