workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

port        ENV['PORT']     || 10000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end