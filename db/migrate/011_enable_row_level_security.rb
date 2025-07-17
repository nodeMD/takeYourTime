class EnableRowLevelSecurity < ActiveRecord::Migration[6.0]
  def up
    # Enable RLS on the database
    database_name = ActiveRecord::Base.connection.current_database
    execute "ALTER DATABASE \"#{database_name}\" SET row_security = on;"

    # Enable RLS on tables with their specific policies

    # 1. checklists table
    execute "ALTER TABLE checklists ENABLE ROW LEVEL SECURITY;"
    execute <<-SQL
      DROP POLICY IF EXISTS "Users can access their own checklists" ON checklists;
      CREATE POLICY "Users can access their own checklists" 
      ON checklists 
      FOR ALL 
      TO public 
      USING (user_id = current_setting('app.current_user_id')::bigint);
    SQL

    # 2. checklist_items table (references checklists)
    execute "ALTER TABLE checklist_items ENABLE ROW LEVEL SECURITY;"
    execute <<-SQL
      DROP POLICY IF EXISTS "Users can access their own checklist_items" ON checklist_items;
      CREATE POLICY "Users can access their own checklist_items" 
      ON checklist_items 
      FOR ALL 
      TO public 
      USING (EXISTS (
        SELECT 1 FROM checklists 
        WHERE checklists.id = checklist_items.checklist_id 
        AND checklists.user_id = current_setting('app.current_user_id')::bigint
      ));
    SQL

    # 3. Other user-related tables
    tables = [:emotions, :esteems, :needs, :stoppers, :wants]

    tables.each do |table|
      execute "ALTER TABLE #{table} ENABLE ROW LEVEL SECURITY;"

      execute <<-SQL
        DROP POLICY IF EXISTS "Users can access their own #{table}" ON #{table};
        CREATE POLICY "Users can access their own #{table}" 
        ON #{table} 
        FOR ALL 
        TO public 
        USING (user_id = current_setting('app.current_user_id')::bigint);
      SQL
    end
  end

  def down
    # Disable RLS on all tables
    tables = [
      :checklist_items, :checklists,
      :emotions, :esteems, :needs, :stoppers, :wants
    ]

    tables.each do |table|
      execute "DROP POLICY IF EXISTS \"Users can access their own #{table}\" ON #{table} CASCADE;"
      execute "ALTER TABLE #{table} DISABLE ROW LEVEL SECURITY;"
    end

    # Reset database RLS setting
    database_name = ActiveRecord::Base.connection.current_database
    execute "ALTER DATABASE \"#{database_name}\" SET row_security = off;"
  end
end
