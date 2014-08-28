# User Model
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :email

  has_many :w000ts, dependent: :destroy
end
