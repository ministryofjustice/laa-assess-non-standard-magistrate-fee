namespace :redis do
  desc "Check connection to redis server"
  task check_connection: :environment do
    redis_conn = Sidekiq.redis { |conn| conn.info }
    if redis_conn.present?
      print "Sidekiq was able to establish connection with Redis server"
    else
      print "Sidekiq unable able to establish connection with Redis server"
    end
  rescue Redis::CannotConnectError, RedisClient::CannotConnectError
    print "Sidekiq unable able to establish connection with Redis server"
  end
end
