require 'bundler/capistrano'
set :application, "api.finfore.net"
set :repository,  "git@github.com:FinforeOrg/FastND.git"
set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/var/www/FastND"

# since we're using assets pipelining feature of rails 3.2
# we don't need this, turning this to true will makes capistrano throw some warning
# regarding missing asset folders
set :normalize_asset_timestamps, false

set :user, "staging"
set :use_sudo, true
set :keep_releases, 10

role :web, application                   # Your HTTP server, Apache/etc
role :app, application                   # This may be the same as your `Web` server
role :db,  application, :primary => true # This is where Rails migrations will run

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  task :sysmlink_shared_assets do
    run "ln -nfs #{shared_path}/config/mongoid.yml #{release_path}/config/mongoid.yml"
    run "ln -nfs #{shared_path}/tmp #{release_path}/tmp"
    run "rm -nfs #{release_path}/public"
    run "ln -nfs #{shared_path}/public #{release_path}/public"
  end
end

after "deploy:finalize_update", "deploy:symlink_shared_assets"
