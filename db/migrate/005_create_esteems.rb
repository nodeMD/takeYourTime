class CreateEsteems < ActiveRecord::Migration[6.0]
  def change
    create_table :esteems do |t|
      t.references :user, foreign_key: true
      t.boolean :esteem, null: false
      t.timestamps
    end
  end
end
