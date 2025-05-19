class AddForeignKeyWithCascadeToEsteems < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :esteems, :users
    add_foreign_key :esteems, :users, on_delete: :cascade
  end
end
