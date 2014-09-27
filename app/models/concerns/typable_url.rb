# Guess type from url
module TypableUrl
  extend ActiveSupport::Concern

  TYPES = [
    :image, :pdf, :github, :soundcloud,
    :youtube, :stack_overflow, :hackernews
  ]

  included do
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

  protected

  def image
    /.+\.(gif|png|jpg|jpeg)\Z/ =~ url
  end

  def pdf
    /.+\.pdf\Z/ =~ url
  end

  def github
    %r{\Ahttps://github\.com} =~ url
  end

  def soundcloud
    %r{\Ahttps://soundcloud\.com} =~ url
  end

  def youtube
    %r{\Ahttps?://www\.youtube\.com} =~ url
  end

  def stack_overflow
    %r{\Ahttp://stackoverflow\.com} =~ url
  end

  def hackernews
    %r{\Ahttps://news\.ycombinator\.com} =~ url
  end
end
