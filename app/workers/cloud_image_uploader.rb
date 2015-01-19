# Workers
class CloudImageUploader
  include Sidekiq::Worker

  def perform(w000t_id)
    logger.info "=== Uploading === loading the w000t... #{w000t_id}"
    w = W000t.find(w000t_id)
    logger.info '=== Uploading === got the w000t...'

    logger.info "=== Uploading === got the url_info... #{w.url_info.url}"
    logger.info '=== Uploading === creating the image object'
    # Create the image object
    w.url_info.cloud_image = ImageUploader.new
    # check error
    logger.info '=== Uploading === image object created'

    # Download the image
    logger.info '=== Uploading === Downloading image....'
    begin
      w.url_info.cloud_image.download!(w.url_info_url)
    rescue CarrierWave::DownloadError => e
      logger.info "Failed to download image : #{e}"
      w.url_info.internal_status = :error
      w.save
      return
    rescue CarrierWave::ProcessingError => e
      logger.info "Failed to proccess image : #{e}"
      w.url_info.internal_status = :error
      w.save
      return
    end

    logger.info '=== Uploading === saving image to the cloud....'
    # Save the image in the cloud
    fnret = w.url_info.cloud_image.store!
    # Check error
    logger.info "=== Uploading === #{fnret} === Image saved"
    w.url_info.cloud_image_urls = {
      url: w.url_info.cloud_image.url,
      thumb_url: w.url_info.cloud_image.thumb.url
    }
    w.url_info.internal_status = :done
    fnret = w.save

    logger.info "=== Uploading === #{fnret} === file uploaded #{w.short_url}"
    logger.info "=== Uploading === cloud_image #{w.url_info.cloud_image}"
  end
end
