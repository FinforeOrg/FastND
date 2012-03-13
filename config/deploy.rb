require 'bundler/capistrano'
set :application, "FastND"
set :domain, "api.finfore.net"
set :repository,  "git@github.com:FinforeOrg/FastND.git"
set :scm, :git
set :branch, "master"
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/var/www/FastND"

# since we're using assets pipelining feature of rails 3.2
# we don't need this, turning this to true will makes capistrano throw some warning
# regarding missing asset folders
set :normalize_asset_timestamps, false
set :port, 9847
set :user, "staging"
set :use_sudo, true
set :keep_releases, 10
set :default_environment, {
  'PATH' => "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH"
}

role :web, domain                   # Your HTTP server, Apache/etc
role :app, domain                   # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  task :symlink_shared_assets do
    run "ln -nfs #{shared_path}/config/mongoid.yml #{release_path}/config/mongoid.yml"
    run "ln -nfs #{shared_path}/tmp #{release_path}/tmp"
    run "ln -nfs #{shared_path}/log #{release_path}/log"
    run "ln -nfs #{shared_path}/public #{release_path}/public"
  end
  task :create_db_index do
    run "cd #{release_path} && rake db:mongoid:create_indexes RAILS_ENV=production"
  end
end

after "deploy:finalize_update", "deploy:symlink_shared_assets"
after "deploy:finalize_update", "deploy:create_db_index"
