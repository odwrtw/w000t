# Add token to class
module Tokenable
  extend ActiveSupport::Concern

  included do
    field :token, type: String

    index({ token: 1 }, { name: 'authentication_token_index_on_token' })

    before_create :generate_token
  end

  protected

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless self.class.find_by(token: random_token)
    end
  end
end
