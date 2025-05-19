class CreateChecklistItems < ActiveRecord::Migration[6.0]
  def change
    create_table :checklist_items do |t|
      t.references :checklist, foreign_key: true, null: false
      t.string :name, null: false, limit: 200
      t.boolean :completed, default: false, null: false
      t.timestamps
    end
  end
end
