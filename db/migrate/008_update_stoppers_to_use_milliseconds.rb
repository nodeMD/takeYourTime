class UpdateStoppersToUseMilliseconds < ActiveRecord::Migration[6.0]
  def change
    # Add milliseconds column if it doesn't exist
    unless column_exists?(:stoppers, :milliseconds)
      add_column :stoppers, :milliseconds, :integer, default: 0, null: false
    end

    # Update existing records to convert time to milliseconds if needed
    reversible do |dir|
      dir.up do
        ActiveRecord::Base.connection.execute("UPDATE stoppers SET milliseconds = time * 1000 WHERE milliseconds IS NULL")
      end

      dir.down do
        ActiveRecord::Base.connection.execute("UPDATE stoppers SET time = milliseconds / 1000")
      end
    end

    # Remove old time column if it exists and rename milliseconds to time
    if column_exists?(:stoppers, :time)
      remove_column :stoppers, :time
      rename_column :stoppers, :milliseconds, :time
    end
  end
end
