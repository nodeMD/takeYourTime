class ChecklistItem < ActiveRecord::Base
  belongs_to :checklist

  validates :name, presence: true, length: { maximum: 200 }
end
