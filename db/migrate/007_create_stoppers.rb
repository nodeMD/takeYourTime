class CreateStoppers < ActiveRecord::Migration[6.0]
  def change
    create_table :stoppers do |t|
      t.references :user, foreign_key: true, null: false
      t.integer :time, default: 0, null: false
      t.boolean :running, default: false, null: false
      t.timestamps
    end
  end
end
