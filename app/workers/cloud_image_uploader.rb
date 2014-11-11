# Workers
class CloudImageUploader
  include Sidekiq::Worker

  def perform(w000t_id)
    logger.info "=== Uploading === loading the w000t... #{w000t_id}"
    w = W000t.find(w000t_id)
    logger.info '=== Uploading === got the w000t...'

    u = w.url_info
    logger.info "=== Uploading === got the url_info... #{u.url}"
    logger.info '=== Uploading === creating the image object'
    # Create the image object
    w.url_info.cloud_image = ImageUploader.new
    # check error
    logger.info '=== Uploading === image object created'

    logger.info '=== Uploading === Downloading image....'
    # Download the image
    fnret = w.url_info.cloud_image.download!(w.url_info_url)
    # Check error
    logger.info "=== Uploading === #{fnret} === image downloaded...."

    logger.info '=== Uploading === saving image to the cloud....'
    # Save the image in the cloud
    fnret = w.url_info.cloud_image.store!
    # Check error
    logger.info "=== Uploading === #{fnret} === Image saved"
    w.url_info.cloud_image_urls = {
      url: w.url_info.cloud_image.url,
      thumb_url: w.url_info.cloud_image.thumb.url
    }
    fnret = w.save

    logger.info "=== Uploading === #{fnret} === file uploaded #{w.short_url}"
    logger.info "=== Uploading === cloud_image #{w.url_info.cloud_image}"
  end
end
