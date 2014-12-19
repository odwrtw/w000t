# Workers
class UploadChecker
  include Sidekiq::Worker

  def perform(w000t_id)
    logger.info "=== Checking upload of w000t === with id #{w000t_id}"
    w = W000t.find(w000t_id)
    unless w
      logger.info "=== Checking upload === no w000t with id #{w000t_id}"
      fail "No w000t with id #{w000t_id}"
    end
    logger.info "=== Checking upload === of url #{w.url_info.url}"

    unless /\Ahttp/ =~ w.url_info.cloud_image.url
      logger.info "=== Not Yet Uploaded === of url #{w.url_info.url}"
      fail 'Not yet uploaded'
    end
    logger.info "=== Uploaded!!! === of url #{w.url_info.cloud_image.url}"
    w.url_info.url = w.url_info.cloud_image.url
    w.url_info.internal_status = :done
    w.save
    UrlLifeChecker.perform_async(w.short_url)
    logger.info "=== Uploaded OVER !!! === of url #{w.url_info.cloud_image.url}"
  end
end
