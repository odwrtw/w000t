# Migrations
require 'json'

result = {}

file = File.open('beautiful_w000t.json')
contents = ''
file.each do |line|
  contents << line
end

redis_data = JSON.parse(contents)
redis_data = redis_data[0]

redis_data['user_id_to_user_name'].each do |id, user|
  puts "================== #{user}"
  result[user] = []
  next unless user == 'pouulet'
  redis_data["user:#{id}:w000t_list"].each do |long_url|
    redis_data['short_to_url_id'].each do |short_url, id_long|
      plop = redis_data["url:#{id_long}"]
      l = plop['url']
      nb = plop['nbOfAccess'] || 0
      next unless short_url
      next unless long_url =~ /^http/
      next unless l =~ /^http/
      if l == long_url
        puts "====== #{user} / #{short_url} / #{long_url} ===="
        result[user] << {
          long_url: long_url,
          short_url: short_url,
          nb_of_access: nb
        }
        W000t.create(
          long_url: long_url,
          short_url: short_url,
          number_of_click: nb,
          user_id: '5404f759626f6f58db010000'
        )
        break
      end
    end
  end
end

puts result['louis'].length
puts result['greg'].length
puts result['pouulet'].length
puts result['julien'].length
