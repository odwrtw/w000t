# encoding: utf-8

# Image class
class ImageUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick

  def cache_dir
    "#{Rails.root}/tmp/images"
  end

  def default_url
    model.url
  end

  def filename
    "#{model.id}_#{original_filename}" if original_filename.present?
  end

  # Process files as they are uploaded:
  # process resize_to_fit: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  version :thumb do
    process resize_to_limit: [400, 0]
  end
end
