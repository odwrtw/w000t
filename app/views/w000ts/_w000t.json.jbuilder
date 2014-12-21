# General infos
json.id w000t.id
json.url w000t.url_info.url
json.w000t w000t.full_shortened_url(request.base_url)
json.type w000t.url_info.type

# w000t of a specific user
if current_user && (current_user == w000t.user || current_user.admin?)
  json.extract! w000t, :number_of_click, :created_at
  json.tags w000t.tags_array
  json.status w000t.status
end

# w000t with no user, totally public
json.extract! w000t, :number_of_click, :created_at unless w000t.user
