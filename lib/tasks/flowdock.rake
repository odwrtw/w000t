require 'flowdock'

API_TOKEN = '44b192ca3591cca9ab50390080b3b77e'

# Create a new flow
flow = Flowdock::Flow.new(
  api_token: API_TOKEN,
  source: 'w000t Mina',
  from: { name: 'w000t Bot', address: 'bot@w000t.me' }
)

namespace :flowdock do

  desc 'Push message to team inbox'
  task :nofify_deploy, [:server] do |t, args|
    link = 'http://w000t.me'
    unless args[:server] == 'production'
      link = "http://#{args[:server]}.w000t.me"
    end
    flow.push_to_team_inbox(
      subject: 'Mina',
      content: "Deployed to #{args[:server]}. Let's try it now ;)",
      tags: ['mina', args[:server].to_s],
      link: link
    )
  end

end
