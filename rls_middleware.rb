class RLSmiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # Get the current user from the session
    session = env["rack.session"]
    user_id = session && session["user_id"]

    # Set the current user ID in a thread-local variable
    Thread.current[:current_user_id] = user_id

    # Set the current user ID for the database connection
    if user_id
      # Use a connection from the pool and set the user ID
      ActiveRecord::Base.connection_pool.with_connection do |connection|
        # Set the user ID for this connection
        connection.execute("SET LOCAL app.current_user_id = #{user_id.to_i}")

        # Process the request with the connection
        @app.call(env)
      end
    else
      # No user logged in, just process the request
      @app.call(env)
    end
  ensure
    # Clear the user ID after the request is complete
    Thread.current[:current_user_id] = nil
  end
end
