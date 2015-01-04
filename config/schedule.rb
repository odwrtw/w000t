require './config/environment.rb'

# Use this file to easily define all of your cron jobs.
set :output, "#{Rails.root}/log/cron_log.log"

# Run every 30 minutes to check on part of all the w000ts that haven't been
# checked for more that 24 hours
every 30.minutes do
  rake 'w000t:check_old_w000ts'
end
