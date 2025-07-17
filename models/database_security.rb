module DatabaseSecurity
  def self.set_current_user(user_id)
    # Set the current user ID for RLS
    DB.run("SET LOCAL app.current_user_id = ?", user_id) if user_id
  rescue => e
    # Log the error but don't crash the app
    puts "Error setting current user for RLS: #{e.message}"
  end

  # This method should be included in your base model or application controller
  def with_current_user(user_id)
    previous_user_id = Thread.current[:current_user_id]
    Thread.current[:current_user_id] = user_id

    begin
      # Set the user ID for this database connection
      DatabaseSecurity.set_current_user(user_id)
      yield
    ensure
      # Restore the previous user ID
      Thread.current[:current_user_id] = previous_user_id
      DatabaseSecurity.set_current_user(previous_user_id)
    end
  end
end
