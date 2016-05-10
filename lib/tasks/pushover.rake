require 'rushover'

APPLICATION_KEY = 'aQStcsBai8cpQqm661EarmkhTEojQG'
USER_KEY = 'gDJi7GN3q9koHiTxSnMqcUCr1BPb8y'

namespace :pushover do
  desc 'Push a notification to all the devices'
  task :notify, [:message, :priority, :title] do |t, args|
    args[:title] ||= 'w000t'
    args[:priority] ||= 0
    client = Rushover::Client.new(APPLICATION_KEY)
    resp = client.notify(USER_KEY,
                         args[:message],
                         priority: args[:priority],
                         title: args[:title],
                         expire: 180,
                         retry: 60)
    puts "Response : #{resp}"
  end
end
