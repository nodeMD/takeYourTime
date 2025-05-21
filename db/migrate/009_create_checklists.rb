class CreateChecklists < ActiveRecord::Migration[6.0]
  def change
    create_table :checklists do |t|
      t.references :user, foreign_key: true, null: false
      t.string :name, null: false, limit: 100
      t.timestamps
    end
  end
end
