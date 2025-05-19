class Checklist < ActiveRecord::Base
  belongs_to :user
  has_many :checklist_items, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }

  def completed_items_count
    checklist_items.where(completed: true).count
  end

  def total_items_count
    checklist_items.count
  end

  def completion_percentage
    return 0 if total_items_count.zero?
    (completed_items_count.to_f / total_items_count * 100).round(1)
  end
end
