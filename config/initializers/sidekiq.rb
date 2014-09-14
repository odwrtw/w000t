server = ENV['REDIS_PORT_6379_TCP_ADDR'] || '127.0.0.1'
port = 6379
namespace = 'sidekiq_w000t'

Sidekiq.configure_server do |config|
  config.redis = {
    url: "redis://#{server}:#{port}",
    namespace: namespace
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: "redis://#{server}:#{port}",
    namespace: namespace
  }
end
