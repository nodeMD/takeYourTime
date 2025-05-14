class Need < ActiveRecord::Base
  belongs_to :user

  validates :what, presence: true, length: {maximum: 1000}
end
