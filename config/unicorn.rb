rails_env = ENV['RAILS_ENV'] || 'production'

if rails_env == 'development'
  app_root = '/Users/guto/work/freelance/fastnd/fastND'
else
  app_root = '/var/www/FastND'
end

worker_processes 4

working_directory app_root.to_s

listen "#{app_root}/tmp/sockets/unicorn.sock", :backlog => 2048

timeout 30

shared_path = "/Users/guto/work/freelance/fastnd/FastND"

pid = "#{app_root}/tmp/pids/unicorn.pid"

stderr_path = "#{app_root}/log/unicorn.stderr.log"
stdout_path = "#{app_root}/log/unicorn.stdout.log"

before_fork do |server, worker|
# This option works in together with preload_app true setting
# What is does is prevent the master process from holding
# the database connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
# Here we are establishing the connection after forking worker
# processes
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
