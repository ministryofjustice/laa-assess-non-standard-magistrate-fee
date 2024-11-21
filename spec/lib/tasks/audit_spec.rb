require 'rails_helper'

describe 'audit:', type: :task do
  let(:fixed_arbitrary_date) { DateTime.new(2023, 12, 3, 12, 3, 12) }
  let(:user) { create(:caseworker) }
  let(:submission) { build(:claim) }

  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    create :access_log,
           user: user,
           submission_id: submission.id,
           created_at: fixed_arbitrary_date,
           path: '/foo',
           controller: 'claims',
           action: 'show'
  end

  describe 'user' do
    subject { Rake::Task['audit:user'].invoke(user.id, '2023-12-3', '2023-12-4') }

    after { Rake::Task['audit:user'].reenable }

    let(:expected_output) { "2023-12-03 12:03:12 UTC,claims,show,#{submission.id},,/foo\n" }

    it 'calls the service' do
      expect { subject }.to output(expected_output).to_stdout
    end
  end

  describe 'submission' do
    subject { Rake::Task['audit:submission'].invoke(submission.id, '2023-12-3', '2023-12-4') }

    after { Rake::Task['audit:submission'].reenable }

    let(:expected_output) { "2023-12-03 12:03:12 UTC,#{user.id},claims,show,,/foo\n" }

    it 'calls the service' do
      expect { subject }.to output(expected_output).to_stdout
    end
  end
end
