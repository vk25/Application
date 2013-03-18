# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  username        :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)
#  remember_token  :string(255)
#  admin           :boolean          default(FALSE)
#

class User < ActiveRecord::Base
  attr_accessible :email, :name, :username, :password, :password_confirmation
  has_many :microposts, dependent: :destroy #destroyes the dependent microposts
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  
  has_secure_password

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token

  validates :name, presence: true, length: { maximum: 50 }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
  				uniqueness: { case_sensitive: false }

  #...................Additional Username.............................
  VALID_USERNAME_REGEX = /\A\w+\z/i  #Only letters, numbers & underscore
  validates :username, presence: true, format: { with: VALID_USERNAME_REGEX },
  				uniqueness: { case_sensitive: false }

  validates :password, length: { minimum: 6 }
  validates :password_confirmation, presence: true


  def feed
    Micropost.where("user_id = ?", id)
  end

  private
    def create_remember_token
          self.remember_token = SecureRandom.urlsafe_base64
    end

end
