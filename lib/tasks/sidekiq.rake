namespace :sidekiq do
  desc 'w000t | Stop sidekiq'
  task :stop do
    system *%W(bin/background_jobs stop)
  end

  desc 'w000t | Start sidekiq'
  task :start do
    system *%W(bin/background_jobs start)
  end

  desc 'w000t | Restart sidekiq'
  task :restart do
    system *%W(bin/background_jobs restart)
  end

  desc 'w000t | Start sidekiq with launchd'
  task :launchd do
    system *%W(bin/background_jobs start_no_deamonize)
  end
end
