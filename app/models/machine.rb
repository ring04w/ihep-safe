class Machine < ActiveRecord::Base
  enum status: [:waiting,:scanned,:scanning,:unknown]
  scope :need_scan, -> { where("status < 3") }

  belongs_to :user
  has_many :results
  validates :user_id, :presence => true
  validates :ip, :presence => true
  validates :status, :presence => true
  validates :ip, :uniqueness => true
  validates :ip, :format => { :with => Resolv::IPv4::Regex }
end
