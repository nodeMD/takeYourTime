require "logger"
require "active_support/logger_thread_safe_level"
require "dotenv/load"
require "./app"
require "sinatra/activerecord/rake"

# Set environment
ENV["RACK_ENV"] ||= "development"

# Configure database connection for Rake tasks
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || {
  adapter: 'postgresql',
  database: ENV['DB_NAME'],
  username: ENV['DB_USERNAME'],
  password: ENV['DB_PASSWORD'],
  host: ENV['DB_HOST'],
  port: ENV['DB_PORT'],
  sslmode: 'require',
  sslrootcert: ENV['DB_SSLROOTCERT'] || './config/supabase-ca-cert.crt'
})
