workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

port        ENV['PORT']     || 10000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Reconnect to the database
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection(
      adapter:  'postgresql',
      database: ENV['DB_NAME'],
      username: ENV['DB_USERNAME'],
      password: ENV['DB_PASSWORD'],
      host:     ENV['DB_HOST'],
      port:     ENV['DB_PORT'] || 5432,
      sslmode:  'require',
      sslrootcert: ENV['DB_SSLROOTCERT'] || './config/supabase-ca-cert.crt',
      prepared_statements: false
    )
  end
end

before_fork do
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection_pool.disconnect!
  end
end
