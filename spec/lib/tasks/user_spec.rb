require 'rails_helper'

describe 'user:', type: :task do
  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
  end

  describe 'deactivate' do
    subject(:run) do
      Rake::Task['user:deactivate'].execute(arguments)
    end

    let(:user) { create(:caseworker, email: 'active-cw@test.com') }
    let(:arguments) { Rake::TaskArguments.new [:email], [user.email] }
    let(:expected_output) { "User email: #{user.email} deactivated at 2024-12-19 12:00:00 UTC\n" }

    after { Rake::Task['user:deactivate'].reenable }

    it 'calls the service' do
      travel_to Time.zone.local(2024, 12, 19, 12) do
        expect { run }.to output(expected_output).to_stdout
      end
    end

    it 'sets activated_at to time' do
      travel_to Time.zone.local(2024, 12, 19, 12) do
        expect { run }.to change { user.reload.deactivated_at }
          .from(nil).to(Time.zone.local(2024, 12, 19, 12))
      end
    end
  end

  describe 'reactivate' do
    subject(:run) do
      Rake::Task['user:reactivate'].execute(arguments)
    end

    let(:user) { create(:caseworker, :deactivated, email: 'deactivate-cw@test.com') }
    let(:arguments) { Rake::TaskArguments.new [:email], [user.email] }
    let(:expected_output) { "User email: #{user.email} reactivated\n" }

    after { Rake::Task['user:reactivate'].reenable }

    it 'calls the service' do
      expect { run }.to output(expected_output).to_stdout
    end

    it 'sets activated_at to nil' do
      travel_to Time.zone.local(2024, 12, 19, 12) do
        expect { run }.to change { user.reload.deactivated_at }
          .from(Time.zone.local(2024, 12, 19, 12)).to(nil)
      end
    end
  end
end
