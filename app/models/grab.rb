class Grab < ActiveRecord::Base
  validates :links, :company, presence: true
  has_many :profiles, dependent: :destroy
end
