# AuthenticationToken
class AuthenticationToken
  include Mongoid::Document
  include Tokenable
  field :name, type: String
  field :token, type: String

  # Association
  belongs_to :user
  delegate :pseudo, :email, to: :user, prefix: true
end
