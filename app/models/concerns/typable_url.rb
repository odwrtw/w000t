# Guess type from url
module TypableUrl
  extend ActiveSupport::Concern

  TYPES = %i(
    image pdf github soundcloud youtube stack_overflow hackernews
  )

  included do
    field :type, type: String

    index({ type: 1 }, { name: 'url_index_on_type' })

    before_save :find_type
  end

  # Mach all the type and update if found
  def find_type(force = 0)
    # Do not check type if type is already defined unless you want to force it
    return if type && force == 0
    self.type = nil
    TYPES.each do |type|
      method(type).call && (return self.type = type)
    end
  end

  # TODO : find a better solution to handle all the cases
  def youtube_id
    return unless type.eql? 'youtube'
    match = /watch\?v=(?<id>[^&]+)/.match(url)
    return unless match
    match[:id]
  end

  protected

  def image
    /.+\.(gif|png|jpg|jpeg)\Z/i =~ url
  end

  def pdf
    /.+\.pdf\Z/ =~ url
  end

  def github
    %r{\Ahttps?://github\.com} =~ url
  end

  def soundcloud
    %r{\Ahttps?://soundcloud\.com} =~ url
  end

  def youtube
    %r{\Ahttps?://www\.youtube\.com} =~ url
  end

  def stack_overflow
    %r{\Ahttps?://stackoverflow\.com} =~ url
  end

  def hackernews
    %r{\Ahttps?://news\.ycombinator\.com} =~ url
  end
end
