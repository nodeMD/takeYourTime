class EnableRlsOnPublicTables < ActiveRecord::Migration[6.1]
  def up
    # Enable RLS on the users table
    execute "ALTER TABLE users ENABLE ROW LEVEL SECURITY;"

    # Add policies for the users table
    execute <<-SQL
      DROP POLICY IF EXISTS "Users can view their own profile" ON users;
      DROP POLICY IF EXISTS "Users can update their own profile" ON users;
      
      CREATE POLICY "Users can view their own profile" 
      ON users FOR SELECT 
      USING (id = current_setting('app.current_user_id', true)::integer);
      
      CREATE POLICY "Users can update their own profile"
      ON users FOR UPDATE
      USING (id = current_setting('app.current_user_id', true)::integer);
    SQL

    # For system tables, we'll just enable RLS without strict policies
    # as they are managed by Rails
    execute "ALTER TABLE schema_migrations ENABLE ROW LEVEL SECURITY;"
    execute "ALTER TABLE ar_internal_metadata ENABLE ROW LEVEL SECURITY;"
  end

  def down
    # Remove policies from users table
    execute 'DROP POLICY IF EXISTS "Users can view their own profile" ON users;'
    execute 'DROP POLICY IF EXISTS "Users can update their own profile" ON users;'

    # Disable RLS on all tables
    execute "ALTER TABLE users DISABLE ROW LEVEL SECURITY;"
    execute "ALTER TABLE schema_migrations DISABLE ROW LEVEL SECURITY;"
    execute "ALTER TABLE ar_internal_metadata DISABLE ROW LEVEL SECURITY;"
  end
end
