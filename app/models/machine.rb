class Machine < ActiveRecord::Base
  enum status: [:waiting,:scanned,:scanning,:unknown]

  belongs_to :user
  validates :user_id, :presence => true
  validates :ip, :presence => true
  validates :status, :presence => true
  validates :ip, :uniqueness => true
  validates :ip, :format => { :with => Resolv::IPv4::Regex }
end
