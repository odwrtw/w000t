# Workers
class UploadChecker
  include Sidekiq::Worker

  def perform(w000t_id)
    logger.info "=== Checking upload of w000t === with id #{w000t_id}"
    w = W000t.find(w000t_id)
    unless w
      logger.info "=== Checking upload === no w000t with id #{w000t_id}"
      raise "No w000t with id #{w000t_id}"
    end
    logger.info "=== Checking upload === of url #{w.url_info.url}"

    logger.info "=== Checking upload === cloud_image? #{w.url_info.cloud_image.inspect}"

    if w.url_info.cloud_image.url.blank?
      logger.info "=== Not Yet Uploaded === of url #{w.url_info.cloud_image.url}"
      raise 'Not yet uploaded'
    end

    logger.info "=== Uploaded!!! === of url #{w.url_info.cloud_image.url}"
    w.url_info.url = w.url_info.cloud_image.url
    w.url_info.internal_status = :done
    w.url_info.save
    UrlLifeChecker.perform_async(w.short_url)
    logger.info "=== Uploaded OVER !!! === of url #{w.url_info.cloud_image.url}"
  end
end
