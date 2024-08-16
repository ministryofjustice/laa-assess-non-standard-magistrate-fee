require 'rails_helper'

describe 'redis_sidekiq:', type: :task do
  describe 'retry_dead_jobs' do
    subject { Rake::Task['redis_sidekiq:retry_dead_jobs'] }

    before do
      Rails.application.load_tasks if Rake::Task.tasks.empty?
    end

    after do
      Rake::Task['redis_sidekiq:retry_dead_jobs'].reenable
    end

    context 'inputs invalid value for days_from_now arg' do
      days_from = "garbage"

      it 'prints out an error' do
        expected_output = "You must enter a valid integer greater than 0"
        expect { Rake::Task['redis_sidekiq:retry_dead_jobs'].invoke(days_from) }.to output(expected_output).to_stdout
      end
    end
  end
end
