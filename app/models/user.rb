class User < ActiveRecord::Base
  enum role: [:member,:admin,:superadmin]
  default_scope -> { order('email DESC') }

  has_many :machines
  validates :name, :presence => true
  validates :role, :presence => true
  validates :name, :length => { :in => 2..50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, :presence => true
  validates :email, :format => { :with => VALID_EMAIL_REGEX }
  validates :email, uniqueness: { case_sensitive: false }

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

end
