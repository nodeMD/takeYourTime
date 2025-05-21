ENV["RACK_ENV"] = "test"
require "dotenv/load"
require "rack/test"
require "rspec"
require "sinatra/activerecord"
require "yaml"
require "erb"
require "database_cleaner/active_record"
require File.expand_path("../app", __dir__)

# Configure DB with ERB processing so .env vars are applied
db_config = YAML.safe_load(ERB.new(File.read("config/database.yml")).result)
ActiveRecord::Base.configurations = db_config
ActiveRecord::Base.establish_connection(:test)

# Run any pending migrations
migration_context = if ActiveRecord::VERSION::MAJOR >= 6
  ActiveRecord::MigrationContext.new("db/migrate", ActiveRecord::SchemaMigration)
else
  ActiveRecord::Migrator
end
migration_context.migrate

RSpec.configure do |config|
  config.include Rack::Test::Methods
  
  # Setup database cleaner
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  def app
    Sinatra::Application
  end
  
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
