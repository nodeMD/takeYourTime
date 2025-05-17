class CreateEmotions < ActiveRecord::Migration[6.0]
  def change
    create_table :emotions do |t|
      t.references :user, foreign_key: true
      t.string :main_emotion, null: false
      t.string :strength, null: false
      t.string :emotion, null: false
      t.timestamps
    end
  end
end
