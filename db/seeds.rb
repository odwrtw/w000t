## Migrations
#require 'json'
#
#result = {}
#users = {}
#
#puts 'Creating the users...'
## Create the users
#%w(PouuleT Greg Julien Louis).each do |username|
#  user = User.create(
#    pseudo: username,
#    email: "#{username}@w000t.me",
#    password: 'testtest'
#  )
#  puts user.inspect
#  users[username.downcase] = { id: user.id }
#  puts users[username]
#end
#
#puts 'Done'
#
#puts 'Parsing the file...'
## Parse the file
#file = File.open('./db/beautiful_w000t.json')
#contents = ''
#file.each do |line|
#  contents << line
#end
#
#redis_data = JSON.parse(contents)
#redis_data = redis_data[0]
#
#puts 'Done'
#
#puts 'Add the w000ts'
## Add the w000ts for each users
#redis_data['user_id_to_user_name'].each do |id, user|
#  puts "Treating #{user}"
#  result[user] = []
#  redis_data["user:#{id}:w000t_list"].each do |long_url|
#    redis_data['short_to_url_id'].each do |short_url, id_long|
#      plop = redis_data["url:#{id_long}"]
#      l = plop['url']
#      nb = plop['nbOfAccess'] || 0
#      next unless short_url
#      next unless long_url =~ /^http/
#      next unless l =~ /^http/
#      if l == long_url
#        puts "====== #{user} / #{short_url} / #{long_url} ===="
#        result[user] << {
#          long_url: long_url,
#          short_url: short_url,
#          nb_of_access: nb
#        }
#        W000t.create(
#          long_url: long_url,
#          short_url: short_url,
#          number_of_click: nb,
#          user_id: users[user][:id]
#        )
#        break
#      end
#    end
#  end
#  puts "#{user} => #{result[user].length}"
#end
#puts 'Down'
