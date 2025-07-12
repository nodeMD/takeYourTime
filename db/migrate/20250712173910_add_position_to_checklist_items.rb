class AddPositionToChecklistItems < ActiveRecord::Migration[6.0]
  def change
    add_column :checklist_items, :position, :integer

    # Set initial positions based on current order
    Checklist.find_each do |checklist|
      checklist.checklist_items.order(:id).each_with_index do |item, index|
        item.update_column(:position, index + 1)
      end
    end

    change_column_null :checklist_items, :position, false
    add_index :checklist_items, [:checklist_id, :position], unique: true
  end
end
