class CreateWants < ActiveRecord::Migration[6.0]
  def change
    create_table :wants do |t|
      t.string :what, limit: 1000, null: false
      t.text :how, limit: 10000
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
