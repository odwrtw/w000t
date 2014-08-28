json.array!(@w000ts) do |w000t|
  json.extract! w000t, :id, :long_url, :short_url
  json.url w000t_url(w000t, format: :json)
end
