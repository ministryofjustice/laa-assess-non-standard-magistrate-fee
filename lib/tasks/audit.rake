namespace :audit do
  desc 'Audit user activity'
  task :user, [:user_id, :from, :to] => [:environment] do |_, args|
    AccessLog.where(user_id: args[:user_id], created_at: Date.parse(args[:from])..Date.parse(args[:to]))
             .order(:created_at)
             .find_each do |log|
      puts "#{log.created_at},#{log.controller},#{log.action},#{log.submission_id},#{log.secondary_id},#{log.path}"
    end
  end

  desc 'Audit submission activity'
  task :submission, [:submission_id, :from, :to] => [:environment] do |_, args|
    AccessLog.where(submission_id: args[:submission_id], created_at: Date.parse(args[:from])..Date.parse(args[:to]))
             .order(:created_at)
             .find_each do |log|
      puts "#{log.created_at},#{log.user_id},#{log.controller},#{log.action},#{log.secondary_id},#{log.path}"
    end
  end
end
