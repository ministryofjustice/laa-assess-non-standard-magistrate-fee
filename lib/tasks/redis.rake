namespace :redis do
  namespace :connection do
    desc "Check connection to redis server"
    task check_connection: :environment do
      redis_conn = Sidekiq.redis { |conn| conn.info }
      if redis_conn.present?
        print "Application was able to establish connection with Redis server"
      else
        print "Application unable able to establish connection with Redis server"
      end
    rescue Redis::CannotConnectError
      print "Application unable able to establish connection with Redis server"
    end
  end
end
