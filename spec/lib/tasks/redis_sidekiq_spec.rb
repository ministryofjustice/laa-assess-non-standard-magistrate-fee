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

    context 'valid value for days_from_now arg' do
      days_from = '1'
      expected_output = "Retried job with jid: 1\nFailed to retry job with jid: 2\n2 job(s) found\n1 job(s) retried"

      before do
        dead_jobs = [
          instance_double(Sidekiq::SortedEntry, at: DateTime.now, retry: true, jid: '1'),
          instance_double(Sidekiq::SortedEntry, at: DateTime.now, retry: false, jid: '2'),
          instance_double(Sidekiq::SortedEntry, at: 2.days.ago, retry: true, jid: '3')
        ]
        allow(Sidekiq::DeadSet).to receive(:new).and_return(dead_jobs)
      end

      it 'accurately reports jobs retried' do
        expect { Rake::Task['redis_sidekiq:retry_dead_jobs'].invoke(days_from) }.to output(expected_output).to_stdout
      end
    end

    context 'inputs invalid value for days_from_now arg' do
      days_from = 'garbage'

      it 'prints out an error' do
        expected_output = 'You must enter a valid integer greater than 0'
        expect { Rake::Task['redis_sidekiq:retry_dead_jobs'].invoke(days_from) }.to output(expected_output).to_stdout
      end
    end
  end
end
