json.array!(@authentication_tokens) do |authentication_token|
  json.extract! authentication_token, :id, :name, :token, :user_id
  json.url authentication_token_url(authentication_token, format: :json)
end
