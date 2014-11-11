# AuthenticationToken
class AuthenticationToken
  include Mongoid::Document
  include Mongoid::Timestamps
  include Tokenable
  field :name, type: String
  field :number_of_use, type: Integer, default: 0

  # Association
  belongs_to :user
  delegate :pseudo, :email, to: :user, prefix: true

  # Model validation
  validates :name, uniqueness: { scope: :user }
end
