# User model
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :w000ts
  has_many :authentication_tokens

  # Model validation
  validates :pseudo, uniqueness: true

  ## Database authenticatable
  field :admin,              type: Boolean, default: false
  field :pseudo,             type: String, default: ''
  field :email,              type: String, default: ''
  field :encrypted_password, type: String, default: ''

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  index({ id: 1 }, name: 'user_index_on_id')
  index({ email: 1 }, name: 'user_index_on_email')
  index({ pseudo: 1 }, name: 'user_index_on_pseudo')

  def will_save_change_to_email?
    false
  end

  def to_param
    pseudo
  end
end
