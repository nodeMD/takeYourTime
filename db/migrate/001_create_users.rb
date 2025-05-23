class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :nickname, null: false
      t.string :password_digest, null: false

      t.timestamps
    end
    add_index :users, :nickname, unique: true
  end
end
