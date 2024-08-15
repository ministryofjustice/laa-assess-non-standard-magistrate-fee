namespace :redis_sidekiq do
  desc "Check connection to redis server"
  task check_connection: :environment do
    redis_conn = Sidekiq.redis { |conn| conn.info }
    if redis_conn.present?
      print "Sidekiq was able to establish connection with Redis server"
    else
      print "Sidekiq unable to establish connection with Redis server"
    end
  rescue Redis::CannotConnectError, RedisClient::CannotConnectError
    print "Sidekiq unable to establish connection with Redis server"
  end

  desc "Retry dead jobs created from now to x days ago"
  task :retry_dead_jobs, [:days_from_now] => [:environment] do |t, args|
    days_from_now = args[:days_from_now].to_i
    if days_from_now == 0
      raise StandardError.new "You must enter a valid integer greater than 0"
    end

    ds = Sidekiq::DeadSet.new
    print "#{ds.size} jobs found"
    if ds.size == 0
      return
    else
      time_from = days_from_now.days.ago
      ds.each do |job|
        #for each dead job, if it died after the downtime was set, retry it
        if job.at  >= time_from
          print job
          job.retry
        end
      end
    end
  end
end
