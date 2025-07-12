class ChecklistItem < ActiveRecord::Base
  belongs_to :checklist

  validates :name, presence: true, length: {maximum: 200}
  validates :position, presence: true, uniqueness: { scope: :checklist_id }
  
  before_validation :set_position, on: :create
  after_destroy :reorder_positions
  
  private
  
  def set_position
    return if position.present? || checklist.blank?
    
    last_position = checklist.checklist_items.maximum(:position) || 0
    self.position = last_position + 1
  end
  
  def reorder_positions
    checklist.checklist_items
            .where('position > ?', position)
            .order(:position)
            .each do |item|
      item.update_column(:position, item.position - 1)
    end
  end
end
