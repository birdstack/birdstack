ssh_options[:port] = 4100

set :application, "birdstack"
set :domain,      "birdstack.com"
set :repository,  "gitosis@git.birdstack.com:#{application}.git"
# cap deploy -s branch=monkeys
set :branch,      "master" unless variables[:branch]
set :user,        "birdstack"
set :use_sudo,    false
set :deploy_to,   "/home/birdstack/birdstack.com"
set :shared_dir, "shared"
set :scm,         "git"
set :deploy_via,  :remote_cache

role :app, domain
role :web, domain
role :db,  domain, :primary => true


desc "Link in the production database.yml, shared configs, etc."
after "deploy:update_code" do
	run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml"
	run "cat #{deploy_to}/#{shared_dir}/config/production.rb >> #{release_path}/config/environments/production.rb"
	
	# Ensure that our deployments use a shared user_data folder
	run "mkdir -p #{deploy_to}/#{shared_dir}/user_data"
	run "rm -rf #{release_path}/user_data"
	run "ln -nfs #{deploy_to}/#{shared_dir}/user_data #{release_path}/user_data"
	
	# Link public user_data into the public dir
	run "ln -nfs #{deploy_to}/#{shared_dir}/user_data/public #{release_path}/public/user_data"

	# And a shared system_data folder
	run "mkdir -p #{deploy_to}/#{shared_dir}/system_data"
	run "rm -rf #{release_path}/system_data"
	run "ln -nfs #{deploy_to}/#{shared_dir}/system_data #{release_path}/system_data"
end

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"

    run "wget localhost:2812/birdstack_background?action=unmonitor -O /dev/null -o /dev/null"
    run "wget localhost:2812/birdstack_delayed_job?action=unmonitor -O /dev/null -o /dev/null"
    run "/etc/init.d/birdstack_background restart"
    run "/etc/init.d/birdstack_delayed_job restart"
    run "wget localhost:2812/birdstack_background?action=monitor -O /dev/null -o /dev/null"
    run "wget localhost:2812/birdstack_delayed_job?action=monitor -O /dev/null -o /dev/null"
  end
end
