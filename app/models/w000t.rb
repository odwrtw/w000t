# w000t model
class W000t
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActionView::Helpers::TextHelper
  require 'digest/sha1'

  field :long_url
  field :short_url
  field :user_id, type: Integer

  belongs_to :user

  # field :_id, type: String, default: ->{ short_url }
  def to_param
    short_url
  end

  def shorten_url(long_url)
    # We hash the long_url
    short_url = Digest::SHA1.hexdigest long_url

    # And we keep only the 10 first characters
    self.short_url = truncate(short_url, length: 10, omission: '')
  end
end
