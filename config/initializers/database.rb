# Set up RLS for database connections
ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.set_callback :checkout, :before do |conn|
  if (user_id = Thread.current[:current_user_id])
    conn.execute("SET app.current_user_id = #{user_id.to_i}")
  end
end

# Include the DatabaseSecurity module in ActiveRecord::Base
ActiveRecord::Base.include(DatabaseSecurity)
