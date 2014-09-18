require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
require 'mina_sidekiq/tasks'
# require 'mina/rvm'    # for rvm support. (http://rvm.io)

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
when 'production'
  set :domain, 'w000t.me'
else
  print_error 'Invalid server.'
  exit
end

set :deploy_to, '/home/deploy/w000t'
set :repository, 'ssh://git@gitlab.quimbo.fr:5022/PouuleT/w000t.git'
set :branch, 'master'
# set :identity_file, '/home/pouulet/id_rsa_w000t'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in
# your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/database.yml', 'log']

# Optional settings:
#   set :user, 'foobar'    # Username in the server to SSH to.
set :port, '2277'     # SSH port number.
set :user, 'deploy'
set :ssh_options, '-A'

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
  invoke :'rbenv:load'
  # Load env variables
  queue  ". ~/.profile"

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use[ruby-1.9.3-p125@default]'
end

task :bower do
  queue %{echo "-----> Running bower install..."}
  queue "bower install"
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task setup: :environment do
  queue! %(mkdir -p "#{deploy_to}/shared/log")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/log")

  queue! %(mkdir -p "#{deploy_to}/shared/config")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/config")

  queue! %(touch "#{deploy_to}/shared/config/database.yml")
  queue %(echo "-----> Be sure to edit 'shared/config/database.yml'.")

  # sidekiq needs a place to store its pid file and log file
  queue! %[mkdir -p "#{deploy_to}/shared/pids/"]
  queue! %[mkdir -p "#{deploy_to}/shared/log/"]
end

desc 'Deploys the current version to the server.'
task deploy: :environment do
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

    to :launch do
      queue "touch #{deploy_to}/tmp/restart.txt"
      invoke :'sidekiq:restart'
    end
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers
