require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv' # for rbenv support. (http://rbenv.org)
require 'mina/whenever'
require 'mina_sidekiq/tasks'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

# Choose the server to deploy_to
server = ENV['server']
unless server
  print_error 'A server needs to be specified. Ex: `mina deploy server=staging`'
  exit
end
case server
when 'staging'
  set :domain, 'staging.w000t.me'
  set :branch, 'staging'
  set :rails_env, 'staging'
when 'production'
  set :domain, 'deploy.w000t.me'
  set :branch, 'master'
  set :rails_env, 'production'
when 'dev'
  set :domain, 'localhost'
  set :branch, 'update'
  set :rails_env, 'staging'
else
  print_error 'Invalid server.'
  exit
end

set :deploy_to, '/home/deploy/w000t'
set :repository, 'https://github.com/odwrtw/w000t.git'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in
# your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_dirs, fetch(:shared_dirs, []).push('log','pids')

# Optional settings:
set :port, '2277' # SSH port number.
set :user, 'deploy'
set :ssh_options, '-A -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
  invoke :'rbenv:load'
  # Load env variables
  command '. ~/.profile'
end

task :bower do
  command %( echo "-----> Running bower install..." )
  command 'bower install'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup do
  command %(mkdir -p "#{fetch(:deploy_to)}/shared/log")
  command %(ln -nfs "/tmp" "#{fetch(:deploy_to)}/current")
  command %(chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/log")

  # sidekiq needs a place to store its pid file and log file
  command %(mkdir -p "#{fetch(:deploy_to)}/shared/pids/")
  command %(mkdir -p "#{fetch(:deploy_to)}/shared/log/")
end

desc 'Notify after installation'
task :notify do
  command %(echo "-----> Notifying the awesome devs")
  command "bundle exec rake pushover:notify['Deployed to #{server}']"
end

desc 'Deploys the current version to the server.'
task :deploy do
  deploy do
    # stop accepting new workers
    invoke :'sidekiq:quiet'

    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'bower'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    on launch: :remote_environment do
      command %(echo "-----> Restarting the server and the sidekiq workers")
      command "mkdir -p #{fetch(:current_path)}/tmp/images"
      command "touch #{fetch(:current_path)}/tmp/restart.txt"
      invoke :'sidekiq:restart'
      invoke :'whenever:clear'
      invoke :'whenever:write'
      if server == 'production'
        invoke :notify
      end
    end

  end
end

desc 'Shows application logs.'
task :logs do
  command %(cd #{fetch(:deploy_to!)} && tail -n 50 -f shared/log/#{server}.log)
end

desc 'Shows sidekiq logs.'
task :sidekiq_logs do
  command %(cd #{fetch(:deploy_to!)} && tail -n 50 -f shared/log/sidekiq.log)
end

desc 'Shows nginx logs.'
task :nginx_logs do
  command %(tail -n 50 -f /var/log/nginx/access.log)
end
