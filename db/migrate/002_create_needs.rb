class CreateNeeds < ActiveRecord::Migration[6.0]
  def change
    create_table :needs do |t|
      t.string :what, limit: 1000, null: false
      t.text :benefits, limit: 10000
      t.text :cons, limit: 10000
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
