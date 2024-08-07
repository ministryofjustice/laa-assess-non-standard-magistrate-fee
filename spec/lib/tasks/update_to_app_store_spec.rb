require 'rails_helper'

describe 'update_to_app_store:', type: :task do
  describe 'sync_autogrant_events' do
    subject { Rake::Task['update_to_app_store:sync_autogrant_events'] }

    let(:autogrant_submission) { create(:prior_authority_application, events: [create(:event, :auto_decision)]) }
    let(:non_autogrant_submission) { create(:prior_authority_application, events: [create(:event)]) }

    before do
      allow(NotifyEventAppStore).to receive(:perform_later).and_return(true)
      autogrant_submission
      non_autogrant_submission
      Rails.application.load_tasks if Rake::Task.tasks.empty?
    end

    after do
      Rake::Task['update_to_app_store:sync_autogrant_events'].reenable
    end

    it 'runs only for submissions with autogrant events' do
      arguments = [autogrant_submission, non_autogrant_submission].map{ _1.id }.join(",")

      Rake::Task['update_to_app_store:sync_autogrant_events'].invoke(arguments)
      expect(NotifyEventAppStore).to have_received(:perform_later).once
    end
  end
end
